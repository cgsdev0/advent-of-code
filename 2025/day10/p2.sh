#!/bin/bash

. ../../misc/vardump

mkdir -p cache

FILE="$1"

D2B=({0..1}{0..1}{0..1}{0..1})

shwoop() {
  while read -a stuff; do
    local tmp=${stuff[1]}
    local len="${#stuff[@]}"
    stuff[1]="${stuff[len-1]}"
    stuff[len-1]="${tmp}"
    echo "${stuff[@]}"
  done
}

gauss() {
  solved=0
  total=0
  while read -a row; do
    idx="${row[0]}"
    cache_key="cache/${FILE}-$idx"
    ((idx--))
    if [[ -f "$cache_key" ]]; then
      ans=$(cat "$cache_key")
      echo "solved $idx from cache: $ans"
      ((total+=ans))
      continue
    fi
    # buncha parsing bulllllllogna
    requirements="${row[1]}"
    buttons=("${row[@]:2}")
    echo "requirements:"
    vardump requirements
    echo "buttons"
    vardump buttons
    IFS=, read -a reqs <<< $requirements
    unset rows
    local -a rows
    for ((i=0; i<${#reqs[@]}; ++i)); do
      r=()
      for ((j=0; j<${#buttons[@]}; ++j)); do
        IFS=, read -a button <<< "${buttons[j]}"
        contains=0
        for ((k=0; k<${#button[@]}; ++k)); do
          if [[ "${button[k]}" == $i ]]; then
            contains=1
            break
          fi
        done
        r+=($contains)
      done
      rows[i]="${r[@]} ${reqs[i]}"
    done

    local h=0
    local k=0
    local m=${#rows[@]}
    local n=${#r[@]}
    ((n++))
    # wikipedia row echelon form algorithm
    while ((h<m && k<n)); do
      local i_max=0
      local max=0
      for ((i=h;i<m;++i)); do
        r=(${rows[i]})
        local v=${r[k]}
        v=${v//-/}
        if [[ v -gt max ]]; then
          max=$v
          i_max=$i
        fi
      done
      if [[ max -eq 0 ]]; then
        ((k++))
      else
        # swap rows(h, i_max)
        local tmp="${rows[h]}"
        rows[h]="${rows[i_max]}"
        rows[i_max]="$tmp"
        for ((i=0;i<m;++i)); do
          [[ i -eq h ]] && continue
          local row_i=(${rows[i]})
          local row_h=(${rows[h]})
          num=$((row_i[k]))
          denom=$((row_h[k]))
          for ((j=k+1;j<n;++j)); do
            local tnum=${num//-/}
            ((tnum*=row_h[j]))
            # we can't safely divide, so we scale
            # the whole row up to compensate
            if (((tnum%${denom//-/}) != 0)); then
              for((l=0;l<n;++l)); do
                ((row_i[l]*=denom))
              done
              denom=1
              break
            fi
          done
          for ((j=k+1;j<n;++j)); do
            row_i[j]=$((row_i[j]-row_h[j]*num/denom))
          done
          row_i[k]=0
          rows[i]="${row_i[@]}"
        done
        ((h++))
        ((k++))
      fi
    done

    # now the fun begins
    zero=0

    # account for fully zero'd rows
    for((i=0;i<m;i++)); do
      all_zeroes=yes
      for((j=0;j<n;j++)); do
        r=(${rows[i]})
        [[ ${r[j]} == 0 ]] || all_zeroes=
      done
      [[ -n $all_zeroes ]] && ((zero++))
    done

    # calculate remaining free variables
    free=$((n-m-1+zero))
    if [[ free -le 0 ]]; then
      # this puzzle is already solved for us!
      ans=0
      for((i=0;i<n-1;i++)); do
        r=(${rows[i]})
        ((ans+=r[n-1]/r[i]))
      done
      ((solved++))
      ((total+=ans))
      echo "$ans" > "$cache_key"
    else # we have free variables to worry about
      echo "Line number: $((idx+1))"
      echo "Free: $free"
      vardump -r rows
      # we need to unfuck the columns
      for((i=0;i<n-1;i++)); do
        nonzero=0
        for((j=0;j<m;j++)); do
          r=(${rows[j]})
          c=${r[i]}
          if [[ $c != 0 ]]; then
            ((nonzero++))
            col=$j
            row=$i
          fi
        done
        if [[ $nonzero == 1 ]]; then
          if [[ $row -gt $col ]]; then
            # uh oh, its fucked
            for((j=0;j<m;j++)); do
              r=(${rows[j]})
              # swaperoo the column-aroo
              tmp=${r[row]}
              r[row]=${r[col]}
              r[col]=${tmp}
              rows[j]="${r[@]}"
            done
          fi
        fi
      done
      vardump -r rows
      # find the free variables
      free_cols=()
      index=0
      for((i=0;i<n-1;i++)); do
        nonzero=0
        for((j=0;j<m;j++)); do
          r=(${rows[j]})
          c=${r[i]}
          [[ $c == 0 ]] || ((nonzero++))
        done
        if [[ nonzero -gt 1 ]]; then
          [[ index -eq 0 ]] && fstart=$i
          ((free_cols[i]=index++))
        fi
      done
      # find the max req
      max=0
      for((i=0;i<m;i++)); do
        req=${reqs[i]}
        [[ req -gt max ]] && max=$req
      done
      echo MAX: $max

      fend=$((fstart+free))
      smallest=100000000000
      # welcome to hell
      for ((p=0;p<=max;++p)); do
        for ((x=0;x<=(free==3?p:0);++x)); do
          for ((y=0;y<=(free>=2?p-x:0);++y)); do
            valid=1
            ans=$p
            z=$((p-x-y))
            guesses=($z $y $x)
            for((ro=0;ro<m-zero;ro++)); do
              r=(${rows[ro]})
              div=${r[ro]}
              num=${r[n-1]}
              for((co=fstart;co<fend;co++)); do
                guess="${guesses[co-fstart]}"
                thing=${r[co]}
                ((num-=guess*thing))
              done
              # check if num divisible by thing
              abs_num=${num//-/}
              abs_div=${div//-/}
              wtf=${num:0:1}${div:0:1}
              wtf=${wtf//[0-9]/}
              if [[ $num != 0 && $wtf == '-' ]]; then
                valid=
                break
              fi
              if ((abs_num%abs_div != 0)); then
                valid=
                break
              fi
              ((ans+=num/div))
            done

            # we should track a min here
            if [[ -n $valid && $ans -lt $smallest ]]; then
              smallest=$ans
            fi
          done
        done
      done
      ((solved++))
      ((total+=smallest))
      echo "$smallest" > "$cache_key"
    fi
  done
  echo SOLVED: $solved / $idx
  echo TOTAL: $total
}

cat -n "$FILE" \
  | tr '\t' ' ' \
  | tr -s ' ' \
  | cut -d' ' -f2,4- \
  | shwoop \
  | tr -d '{}()' \
  | gauss
