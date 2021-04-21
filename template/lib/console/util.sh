# Simple console util v2.0
# Includes some style/colors and symbols

alias n='normal';
function normal() {
    tput sgr0;
}

alias b='bold';
function bold() {
    tput bold;
}

alias u='underline';
function underline() {
    tput smul;
}

alias r='reverse';
function reverse() {
    tput rev;
}

alias d='dim';
function dim() {
    tput dim;
}


alias bkb="bold;black"
alias bkn="normal;black"
alias bk='black';
function black() {
    tput setaf 1;
}
alias bkbg='blackbg';
function blackbg() {
    tput setab 1;
}

alias rdb="bold;red"
alias rdn="normal;red"
alias rd='red';
function red() {
    tput setaf 1;
}
alias rdbg='redbg';
function redbg() {
    tput setab 1;
}

alias grb="bold;green"
alias grn="normal;green"
alias gr='green';
function green() {
    tput setaf 2;
}
alias grbg='greenbg';
function greenbg() {
    tput setab 2;
}

alias ywb="bold;yellow"
alias ywn="normal;yellow"
alias yw='yellow';
function yellow() {
    tput setaf 3;
}
alias ywbg='yellowbg';
function yellowbg() {
    tput setab 3;
}

alias blb="bold;blue"
alias bln="normal;blue"
alias bl='blue';
function blue() {
    tput setaf 4;
}
alias blbg='bluebg';
function bluebg() {
    tput setab 4;
}

alias mgb="bold;magenta"
alias mgn="normal;magenta"
alias mg='magenta';
function magenta() {
    tput setaf 5;
}
alias mgbg='magentabg';
function magentabg() {
    tput setab 5;
}

alias cyb="bold;cyan"
alias cyn="normal;cyan"
alias cy='cyan';
function cyan() {
    tput setaf 6;
}
alias cnbg='cyanbg';
function cyanbg() {
    tput setab 6;
}

alias whb="bold;white"
alias whn="normal;white"
alias wh='white';
function white() {
    tput setaf 7;
}
alias whbg='whitebg';
function whitebg() {
    tput setab 7;
}


function bigcrossmark() {
    echo '❌'
}
function bigcheckmark() {
    echo '✔';
}

function checkmark() {
    echo '✓';
}
function crossmark() {
    echo '✘'
}

function boxcheckmark() {
    echo '✅';
}
function boxcrossmark() {
    echo '❎'
}

function right() {
    echo "$(green)$(checkmark)$(normal)";
}

function wrong() {
    echo "$(red)$(crossmark)$(normal)";
}


