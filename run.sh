# Simple Bash Module Loader v2.0

# Paste to top of main script

# the 'include' function loads all modules in a path, or a specific file (.sh extension optional)
#    include "${script}";    # Includes module with implicit extension
#    include "${script}.sh"; # Includes module with explicit extension
#    include "${path}";      # Includes a 'default' module, one of ___MODULES_DEFAULTS (ex:. ${path}/main.sh)
#    include "${path}/*";    # Includes all modules in path
#    include "${path}/**";   # Includes all modules in path, recursively
#
# modules are sourced relative to ___MODULES_PATHS, checked in ascending order 
#
# to load files relative to current file, use the 'mypath' alias:
#   include "${relative-path}" "$(mypath)"
#
# For debugging
#    ___MODULE_DEBUG >= 1 -> show modules loaded
#    ___MODULE_DEBUG >= 2 -> show module paths searched

shopt -s expand_aliases
alias myfile='realpath ${BASH_SOURCE[0]}';
alias mypath='dirname $(myfile)';

declare ___MODULES_PATHS=("$(mypath)/template/src" "$(mypath)/template/lib");
declare ___MODULES_DEFAULTS=('main' 'defaut' 'index');
declare -A ___MODULES_LOADED=([$(myfile)]=loaded);
declare ___MODULES_DEBUG=0

function include() {
    local source=$1;

    local bases=;
    [[ -z $2 ]] && bases=("${___MODULES_PATHS[@]}") || bases=("$2", "${___MODULES_PATHS[@]}");

    local modules=();
    
    for base in "${bases[@]}"; do        
        local target=$(realpath "${base}/${source}" 2>/dev/null);
        [[ -z "${target}" ]] && continue;

        # module with sh extension
        (( ___MODULES_DEBUG >= 2 )) && echo "Checking '${target}'..." 1>&2;
        if [[ -f ${target} ]]; then 
            modules=("${target}");
            break;
        fi
        # module without sh extension
        (( ___MODULES_DEBUG >= 2 )) && echo "Checking '${target}.sh'..." 1>&2;
        if [[ -f "${target}.sh" ]]; then
            modules=("${target}.sh");
            break;
        fi
        # all modules in directory
        if [[ "${target}" == *'/*' ]]; then 
            (( ___MODULES_DEBUG >= 2 )) && echo "Checking '${target::-2}/*'..." 1>&2;
            modules=( $(find "${target::-2}" -maxdepth 1 -type f -name '*.sh' 2>/dev/null ) );
            break;
        fi
        # all modules recursively in directory
        if [[ "${target}" == *'/**' ]]; then
            (( ___MODULES_DEBUG >= 2 )) && echo "Checking '${target::-3}/**'..." 1>&2;
            modules=( $(find "${target::-3}" -type f -name '*.sh' 2>/dev/null) );
            break;
        fi        
        # default module in directory
        if [[ -d "${target}" ]]; then
            for default in "${___MODULES_DEFAULTS[@]}"; do
                local deftarget="${target}/${default}.sh";
                (( ___MODULES_DEBUG >= 2 )) && echo "Checking '${deftarget}'..." 1>&2;
                if [[ -f ${deftarget} ]]; then 
                    modules=("${deftarget}");
                    break 2;
                fi      
            done
        fi
    done

    (( "${#modules[@]}" == 0 )) && echo "Could not load '${source}'" 1>&2 && return 1;

    # load modules
    for module in "${modules[@]}"; do
        if [[ -z "${___MODULES_LOADED[$module]}" ]]; then
            (( ${___MODULES_DEBUG} >=1 )) && echo "Loading '${module}'" 1>&2;
            ___MODULES_LOADED["$module"]="loaded";        
            source "$module";
        fi
    done
}

function header() {
    PS="$(ywb)" print "** create-bash-project v1.0.0 **"
}

function main() {
    include 'console/*';
        
    local path=$(mypath);
    local file=$(myfile);

    if [[ "${1}" == '--install' ]]; then
        local target=${2:-"${HOME}/.local/bin"}
        local owd=$(pwd);

        cd "${target}";    
        ln -sv ${file} 'create-bash-project'
        cd "${owd}";

    elif [[ "${1}" == "--version" ]]; then
        header;
    else
        header;

        local name="${1}";

        if [[ -z "${name}" ]]; then
            PS="$(blb)" \
            RS="$(whb)" \
            RV=name prompt ' Enter project name';
        fi

        mkdir -pv "${name}";
        cp -Rv ${path}/template/* "${name}";
    fi
}

main "$@";