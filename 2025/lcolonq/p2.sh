#!/usr/bin/env bash


clear

reverse() {
  local n="$1"
  local i
  if [[ n -eq -1 ]]; then
    n=0
  fi
  local s
  for((i=0; i<7; i++)); do
    s="$s$((n%3))"
    ((n/=3))
  done
  echo $((3#$s))
}

render() {
  local n="$1"
  local i
  local s
  if [[ $n -eq -1 ]]; then
    echo "[]"
    return
  fi
  for((i=0; i<7; i++)); do
    s="$((n%3))$s"
    ((n/=3))
  done
  echo "$s"
}

show_bowls() {
  local i
  echo
  for((i=0;i<5;i++)); do
    if [[ $citrine -eq $i ]]; then
      echo -n "> "
    else
      echo -n "  "
    fi
    render "${bowls[i]}"
  done
}

balance_scales() {
  local leftc rightc diff
  leftc="${#brass_scale_left[@]}"
  rightc="${#brass_scale_right[@]}"
  diff=$((leftc - $rightc))
  if [[ $diff -eq 4 ]]; then
    brass_scale_left=("${brass_scale_left[@]:0:leftc-4}")
  elif [[ $diff -eq -4 ]]; then
    brass_scale_right=("${brass_scale_right[@]:0:rightc-4}")
  fi
}

main() {
  read sigils
  IFS=, read -a runestones
  basin=0 # contains used tuning forks
  lazy_susan_west=-1 # wood bowl
  lazy_susan_east=-1 # stone bowl
  textile_bag=0
  brass_scale_left=()
  brass_scale_right=()
  bowls=(-1 -1 -1 -1 -1) # 5 bowls
  citrine=0 # north
  intensity=1
  for ((i=0;i<${#sigils};i++)); do
    if ((i % 100 == 0)); then
      echo $i
    fi
    sigil="${sigils:i:1}"
    [[ "$sigil" == " " ]] && continue
    case "$sigil" in
      "♊")
        ((next=(citrine+2)%5)) # next, 2 clockwise
        intensity="${bowls[$next]}"
        continue
        ;;
    esac
    for ((j=0; j<intensity; j++)); do
      case "$sigil" in
        "♎")
          leftc="${#brass_scale_left[@]}"
          rightc="${#brass_scale_right[@]}"
          if [[ $leftc -eq $rightc ]]; then
            echo "medium severity"
            exit 1
          fi
          take_from=left
          if [[ $rightc -eq 0 ]]; then
            take_from=left
          elif [[ $leftc -eq 0 ]]; then
            take_from=right
          elif [[ $leftc -gt $rightc ]]; then
            take_from=right
          fi
          if [[ $take_from == "left" ]]; then
            lazy_susan_west="${brass_scale_left[-1]}"
            unset 'brass_scale_left[-1]'
          else
            lazy_susan_west="${brass_scale_right[-1]}"
            unset 'brass_scale_right[-1]'
          fi
          balance_scales
          ;;
        "©")
          temp="$lazy_susan_east"
          lazy_susan_east="$lazy_susan_west"
          lazy_susan_west="$temp"
          ;;
        "♏")
          leftc="${#brass_scale_left[@]}"
          rightc="${#brass_scale_right[@]}"
          if [[ $leftc -eq 0 || $rightc -eq 0 ]]; then
            echo "violation of grievous character"
            exit 1
          fi
          leftd="${brass_scale_left[-1]}"
          rightd="${brass_scale_right[-1]}"
          lazy_susan_east=$(((leftd * rightd) % 2187))
          ;;
        "♉")
          bowls[$citrine]=0
          ((citrine=(citrine+4)%5)) #counter clockwise
          ;;
        "♋")
          ((basin++))
          ((next=(citrine+1)%5)) # next, clockwise
          consult="${bowls[$next]}"
          if [[ $consult -lt 0 ]]; then
            consult=0
            bowls[$next]=$consult
          fi
          lazy_susan_east=$(((lazy_susan_east - consult + 2187)% 2187))
          ;;
        "♒")
          ((citrine=(citrine+1)%5)) # clockwise
          runestone="${bowls[$citrine]}"
          if [[ $runestone -lt 0 ]]; then
            runestone=0
          fi
          bowls[$citrine]=-1
          textile_bag="$runestone"
          ;;
        "♑")
          new=${ reverse "$textile_bag"; }
          bowls[$citrine]="$new"
          ((citrine=(citrine+4)%5)) #counter clockwise
          ;;
        "♐")
          runestone="${lazy_susan_west}"
          if [[ $runestone -lt 0 ]]; then
            runestone=0
          fi
          bowls[$citrine]="$runestone"
          ((citrine=(citrine+4)%5)) #counter clockwise
          ;;
        "♓")
          ((citrine=(citrine+1)%5)) # clockwise
          runestone="${bowls[$citrine]}"
          if [[ $runestone -lt 0 ]]; then
            runestone=0
          fi
          bowls[$citrine]=-1
          brass_scale_left+=("$runestone")
          balance_scales
          ;;
        "♈")
          acolyte="${lazy_susan_west}"
          if [[ $acolyte -lt 0 ]]; then
            acolyte=0
          fi
          consult="${runestones[$acolyte]}"
          if [[ "$consult" == "" ]]; then
            echo "no acolyte found"
            exit 1
          fi
          bowls[$citrine]="$consult"
          ((citrine=(citrine+4)%5)) #counter clockwise
          ;;
        "♍")
          textile_bag="$basin"
          basin=0
          ;;
        "♌")
          brass_scale_left+=("$basin")
          balance_scales
          ;;
        "⏚")
          new="${ reverse "$textile_bag"; }"
          brass_scale_right+=("$new")
          balance_scales
          ;;
        *)
          echo " unknown sigil; ritual failed!"
          exit 1
          ;;
        esac
      done
    intensity=1
  done
  ((next=(citrine+1)%5)) # next, 2 clockwise
  echo "Culmination: ${bowls[$next]}"
}
main < input.txt
