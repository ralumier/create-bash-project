# Simple Bash Dialogs v2.0

# print     - print a prompt
# pause     - simple 'press any key' function
# password  - simple password + confirmation function
# prompt    - prompt with default/options capability
#   ask       - y/n prompt, 0 for yes, 1 for no, can default to y|n
#   query     - prompt until valid response
#   choose    - converts options to numeric menu, prompt until valid response

# Config Variables:
#   NS  => no style             (constant, reserved name)
#
#   PS  => prompt style
#   SS  => separator style      (punctuation)
#
#   DS  => default value style  (default is bold)
#   DV  => default value
#   DD  => default display      (defaults to true, 'f' for false)
#
#   CS  => choice style
#   CT  => choice divide text   (defaults to ,)
#   CD  => choice display       (defaults to true, 'f' for false, overrides DD)
#
#   ES  => ending style         (defaults to SS)
#   ET  => ending text          (default is ': ')
#
#   RS  => response style
#   RV  => response variable
#   RM  => response matching    (default is i (case-insensitive), s for case-sensitive)
#
#   LS  => list number style    (defaults to CS)
#   LN  => list starting number (default is 0)
#
#   GS  => good message style   (affirmation)
#   BS  => bad message style    (error)

# (prompt:string)
function print() {
    local ___PROMPT_prompt=$1;
    local NS=$(tput sgr0);
    echo "${PS}${___PROMPT_prompt}${NS}";
}

# (prompt:string)
function pause() {
    local ___PAUSE_prompt=${1:-"Press any key to continue..."};
    
    local NS=$(tput sgr0);

    read -s -n 1 -p "${PS}${___PAUSE_prompt}${NS}";
    echo;
}

# ()
function password() {
    local ___PASSWORD_0=;
    local ___PASSWORD_1=;
    
    local NS=$(tput sgr0);

    while true; do

        # Password
        IFS= read -p "${PS}Enter password${NS}${ES}${E:-:}${NS} " -s ___PASSWORD_0;        
        if [[ -z "${___PASSWORD_0}" ]]; then
            echo "${BS}no password entered!${NS}" 1>&2s;
            echo;
            continue;
        else
            echo "${GS}ok${NS}";
        fi

        # Confirmation
        IFS= read -p "${PS}Please confirm${NS}${ES}${E:-:}${NS} " -s ___PASSWORD_1;
        if [[ "$___PASSWORD_0" != "$___PASSWORD_1" ]]; then
            echo "${BS}passwords did not match!${NS}" 1>&2;
            echo;
        else
            echo "${GS}ok${NS}";
            break;
        fi
    done
    
    local -n ___PASSWORD_var=${RV:-REPLY};
    ___PASSWORD_var="${___PASSWORD_0}"
}

# (prompt:string, options?:string...)
function prompt() {
    local ___PROMPT_prompt=$1;
    local ___PROMPT_options=( "${@:2}" );
    
    # Default Styles
    local NS=$(tput sgr0);
    [[ -z ${DS} ]] && local DS="$(tput bold)";

    # Style Prompt
    ___PROMPT_prompt="${PS}${___PROMPT_prompt}${NS}";

    # Display Choices
    if [[ ${#___PROMPT_options[@]} > 0 && ${CD^^} != 'F' ]]; then
        local ___PROMPT_prompt_options='';

        for ___PROMPT_option in "${___PROMPT_options[@]}"; do        
            [[ ! -z "${___PROMPT_prompt_options}" ]] && ___PROMPT_prompt_options+="${SS}${CT:-,}${NS}";

            if [[ "$DV" == "${___PROMPT_option}" ]]; then
                ___PROMPT_prompt_options+="${DS}${___PROMPT_option}${NS}";
            else
                ___PROMPT_prompt_options+="${CS}${___PROMPT_option}${NS}";
            fi
        done

        ___PROMPT_prompt="${PS}${___PROMPT_prompt}${NS} ${SS}(${NS}${___PROMPT_prompt_options}${SS})${NS}";

    # Display Default
    elif [[ ! -z "${DV}" && "${DD^^}" != 'F' ]]; then
        ___PROMPT_prompt="${___PROMPT_prompt} ${SS}[${NS}${DS:-$B}${DV}${NS}${SS}]${NS}";
    fi
    
    # Get Input
    local ___PROMPT_reply
    IFS= read -p "${___PROMPT_prompt}${ES:-$SS}${ET:-: }${NS}${RS}" -e ___PROMPT_reply; printf "${NS}";    

    # Default if empty
    if [[ -z "${___PROMPT_reply}" ]]; then ___PROMPT_reply="${DV}"; fi

    # Return reply
    local -n ___PROMPT_var=${RV:-REPLY};

    # If any response valid
    if [[ ${#___PROMPT_options[@]} == 0 ]]; then
        ___PROMPT_var="${___PROMPT_reply}";
        return 0;

    # If response must be from set of options
    else

        # Match response case-sensitively
        if [[ "${RM^^}" == 'S' ]]; then                    
            for ___PROMPT_option in "${___PROMPT_options[@]}"; do
                if [[ "${___PROMPT_reply}" == "${___PROMPT_option}" ]]; then
                    ___PROMPT_var="${___PROMPT_option}";
                    return 0;
                fi
            done

        # Match response case-insensitively
        else
            for ___PROMPT_option in "${___PROMPT_options[@]}"; do
                if [[ "${___PROMPT_reply^^}" == "${___PROMPT_option^^}" ]]; then
                    ___PROMPT_var="${___PROMPT_option}";
                    return 0;
                fi
            done
        fi
    fi

    # Invalid reply
    return 1;
}

# (prompt:string) -> Y=0|N=1
function ask() {
    local ___ASK_prompt="$1";    
        
    local NS=$(tput sgr0);
    [[ -z ${DS} ]] && local DS="$(tput bold)";

    case "${DV^^}" in
        YES|Y)
            ___ASK_prompt="${___ASK_prompt} ${NS}${SS}(${NS}${DS}Y${NS}${SS}/${NS}${CS}n${NS}${SS})${NS}";
            default=0;
            ;;
        NO|N)
            ___ASK_prompt="${___ASK_prompt} ${NS}${SS}(${NS}${CS}y${NS}${SS}/${NS}${DS}N${NS}${SS})${NS}";
            default=1;
            ;;        
        *)
            ___ASK_prompt="${___ASK_prompt} ${NS}${SS}(${NS}${CS}y${NS}${SS}/${NS}${CS}n${NS}${SS})${NS}";
            unset default;
            ;;
    esac

    while true; do
        local ___ASK_reply=;
        RV='___ASK_reply' DD='F' prompt "${___ASK_prompt}";

        [[ -z "${___ASK_reply}" && ! -z "${DV}" ]] && ___ASK_reply="${DV}";

        case "${___ASK_reply^^}" in
            YES|Y)
                return 0;
                ;;
            NO|N)
                return 1;
                ;;
            *)
                echo "${BS}Invalid response.${NS}" 1>&2;
                echo;
                ;;
        esac
    done
}

# (prompt:string, options:string...)
function query() {
    while ! prompt "$@"; do
        echo "${BS}Invalid choice.${NS}";
    done
}

# (prompt:string, options:string...)
function choose() {
    local ___CHOOSE_prompt=$1;
    local ___CHOOSE_options=( "${@:2}" );
    
    [[ ${#___CHOOSE_options[@]} == 0 ]] && echo 'Must provide options' 1>&2 && return 1;
    
    local NS=$(tput sgr0);
    [[ -z ${DS} ]] && local DS="$(tput bold)";

    local ___CHOOSE_number_options=();

    local ___CHOOSE_default_index=;

    [[ -z ${LN} ]] && local LN=0;

    for (( ___CHOOSE_i = 0; ___CHOOSE_i < ${#___CHOOSE_options[@]}; ___CHOOSE_i++ )); do
        
        ___CHOOSE_number_options+=( $(( ___CHOOSE_i + LN )) );

        if [[ "$DV" == "${___CHOOSE_options[___CHOOSE_i]}" ]]; then
            ___CHOOSE_default_index="$((___CHOOSE_i + LN ))";
            echo "${SS}[${NS}${LS}$(( ___CHOOSE_i + LN ))${NS}${SS}]:${NS} ${DS}${___CHOOSE_options[___CHOOSE_i]}${NS}";
        else
            echo "${SS}[${NS}${LS}$(( ___CHOOSE_i + LN ))${NS}${SS}]:${NS} ${CS}${___CHOOSE_options[___CHOOSE_i]}${NS}";
        fi
    done

    local ___CHOOSE_reply=;

    while ! RV='___CHOOSE_reply' \
            DV="${___CHOOSE_default_index}" \
            CD='F' \
            prompt "${___CHOOSE_prompt}" "${___CHOOSE_number_options[@]}"; do
        echo "${BS}Invalid choice.${NS}" 1>&2;
    done

    local -n ___CHOOSE_var=${RV:-REPLY};
    ___CHOOSE_var="${___CHOOSE_options[$((___CHOOSE_reply - LN))]}"
}