# Written by FenrisAureus
# credit to :
# bira
#



# gdate for macOS
# REF: https://apple.stackexchange.com/questions/135742/time-in-milliseconds-since-epoch-in-the-terminal
if [[ "$OSTYPE" == "darwin"* ]]; then
    {
        gdate
    } || {
        echo "\n$fg_bold[yellow]passsion.zsh-theme depends on cmd [gdate] to get current time in milliseconds$reset_color"
        echo "$fg_bold[yellow][gdate] is not installed by default in macOS$reset_color"
        echo "$fg_bold[yellow]to get [gdate] by running:$reset_color"
        echo "$fg_bold[green]brew install coreutils;$reset_color";
        echo "$fg_bold[yellow]\nREF: https://github.com/ChesterYue/ohmyzsh-theme-passion#macos\n$reset_color"
    }
fi


# time
function real_time() {
    local color="%B%{$TIME_COLOR%}";                    # color in PROMPT need format in %{XXX%} which is not same with echo
    local time="[$(date +%H:%M:%S)]";
    local color_reset="%{$reset_color%}";
    echo "${color}${time}${color_reset}";
}

# login_info
function login_info() {
    local color="%{$fg_no_bold[cyan]%}";                    # color in PROMPT need format in %{XXX%} which is not same with echo
    local ip
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        ip="$(ifconfig | grep ^eth1 -A 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        ip="$(ifconfig | grep ^en1 -A 4 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)";
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
    else
        # Unknown.
    fi
    local color_reset="%{$reset_color%}";
    echo "${color}[%n@${ip}]${color_reset}";
}


# directory
function directory() {
    local color="%{$fg_no_bold[cyan]%}";
    # REF: https://stackoverflow.com/questions/25944006/bash-current-working-directory-with-replacing-path-to-home-folder
    local directory="${PWD/#$HOME/~}";
    local color_reset="%{$reset_color%}";
    echo "${color}[${directory}]${color_reset}";
}

# git
BRANCH="\ue0a0"

ZSH_THEME_GIT_PROMPT_PREFIX="%B[$BRANCH(";
ZSH_THEME_GIT_PROMPT_SUFFIX="]";
ZSH_THEME_GIT_PROMPT_DIRTY=")*";
ZSH_THEME_GIT_PROMPT_CLEAN=")";

function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}

function git_status() {
    echo "%{$GIT_COLOR%}${GIT_STATUS}%{$reset_color%}"
}


# command
function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    COMMAND_RESULT=$1;
    export COMMAND_RESULT=$COMMAND_RESULT
    if $COMMAND_RESULT;
    then
        arrow="%{$fg_bold[red]%}❱%{$fg_bold[yellow]%}❱%{$fg_bold[green]%}❱";
    else
        arrow="%{$fg_bold[red]%}❱❱❱";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}
update_command_status true;

function command_status() {
    echo "${COMMAND_STATUS}"
}


# output command execute after
output_command_execute_after() {
    if [ "$COMMAND_TIME_BEIGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEIGIN" = "" ];
    then
        return 1;
    fi

    # cmd
    local cmd="${$(fc -l | tail -1)#*  }";
    local color_cmd="";
    if $1;
    then
        color_cmd="$fg_no_bold[green]";
    else
        color_cmd="$fg_bold[red]";
    fi
    local color_reset="$reset_color";
    cmd="${color_cmd}${cmd}${color_reset}"

    # time
    local time="[$(date +%H:%M:%S)]"
    local color_time="$fg_no_bold[cyan]";
    time="${color_time}${time}${color_reset}";

    # cost
    local time_end="$(current_time_millis)";
    local cost=$(bc -l <<<"${time_end}-${COMMAND_TIME_BEIGIN}");
    COMMAND_TIME_BEIGIN="-20200325"
    local length_cost=${#cost};
    if [ "$length_cost" = "4" ];
    then
        cost="0${cost}"
    fi
    cost="[${cost}s]"
    local color_cost="$fg_no_bold[cyan]";
    cost="${color_cost}${cost}${color_reset}";

    echo -e "${time} ${cost}";
    echo -e "";
}


# command execute before
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
preexec() {
    COMMAND_TIME_BEIGIN="$(current_time_millis)";
}

current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        time_millis="$(date +%s.%3N)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        time_millis="$(gdate +%s.%3N)";
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
    else
        # Unknown.
    fi
    echo $time_millis;
}


# command execute after
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
precmd() {
    # last_cmd
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    # update_git_status
    update_git_status;

    # update_command_status
    update_command_status $last_cmd_result;

    # output command execute after
    output_command_execute_after $last_cmd_result;
}


# set option
setopt PROMPT_SUBST;


# timer
#REF: https://stackoverflow.com/questions/26526175/zsh-menu-completion-causes-problems-after-zle-reset-prompt
TMOUT=1;
TRAPALRM() {
    # $(git_prompt_info) cost too much time which will raise stutters when inputting. so we need to disable it in this occurence.
    # if [ "$WIDGET" != "expand-or-complete" ] && [ "$WIDGET" != "self-insert" ] && [ "$WIDGET" != "backward-delete-char" ]; then
    # black list will not enum it completely. even some pipe broken will appear.
    # so we just put a white list here.
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}



RRED="$(printf '\033[38;2;255;0;0m')"
RORANGE="$(printf '\033[38;2;255;97;0m')"
RYELLOW="$(printf '\033[38;2;247;255;0m')"
RGREEN="$(printf '\033[38;2;0;255;30m')"
RBLUE="$(printf '\033[38;2;77;0;255m')"
RPURPLE="$(printf '\033[38;2;168;0;255m')"
RPINK="$(printf '\033[38;2;245;0;172m')"
RRWHITE="$(printf '\033[38;2;255;255;255m')"


RAINBOW13=(
    ""
    "$(printf '\033[38;2;255;1;0m')"
    "$(printf '\033[38;2;255;59;0m')"
    "$(printf '\033[38;2;255;117;0m')"
    "$(printf '\033[38;2;255;177;0m')"
    "$(printf '\033[38;2;255;236;0m')"
    "$(printf '\033[38;2;177;255;0m')"
    "$(printf '\033[38;2;58;255;0m')"
    "$(printf '\033[38;2;0;255;59m')"
    "$(printf '\033[38;2;0;255;179m')"
    "$(printf '\033[38;2;0;215;255m')"
    "$(printf '\033[38;2;0;98;255m')"
    "$(printf '\033[38;2;21;0;255m')"
    "$(printf '\033[38;2;137;0;255m')"
)

RAINBOW18=(
    ""
    "$(printf '\033[38;2;255;1;0m')"
    "$(printf '\033[38;2;255;43;0m')"
    "$(printf '\033[38;2;255;85;0m')"
    "$(printf '\033[38;2;255;128;0m')"
    "$(printf '\033[38;2;255;170;0m')"
    "$(printf '\033[38;2;255;213;0m')"
    "$(printf '\033[38;2;255;255;0m')"
    "$(printf '\033[38;2;168;255;0m')"
    "$(printf '\033[38;2;85;255;0m')"
    "$(printf '\033[38;2;0;255;2m')"
    "$(printf '\033[38;2;0;255;86m')"
    "$(printf '\033[38;2;0;255;170m')"
    "$(printf '\033[38;2;0;253;255m')"
    "$(printf '\033[38;2;0;170;255m')"
    "$(printf '\033[38;2;0;83;255m')"
    "$(printf '\033[38;2;0;0;255m')"
    "$(printf '\033[38;2;87;0;255m')"
    "$(printf '\033[38;2;170;0;255m')"
)

RAINBOW14=(
    ""
    "$(printf '\033[38;2;255;1;0m')"
    "$(printf '\033[38;2;255;55;0m')"
    "$(printf '\033[38;2;255;110;0m')"
    "$(printf '\033[38;2;255;164;0m')"
    "$(printf '\033[38;2;255;219;0m')"
    "$(printf '\033[38;2;219;255;0m')"
    "$(printf '\033[38;2;109;255;0m')"
    "$(printf '\033[38;2;0;255;2m')"
    "$(printf '\033[38;2;0;255;110m')"
    "$(printf '\033[38;2;0;255;221m')"
    "$(printf '\033[38;2;0;182;255m')"
    "$(printf '\033[38;2;0;72;255m')"
    "$(printf '\033[38;2;36;0;255m')"
    "$(printf '\033[38;2;146;0;255m')"
)

RAINBOW14_WARM=(
    ""
    "$(printf '\033[38;2;239;42;42m')"
    "$(printf '\033[38;2;245;83;35m')"
    "$(printf '\033[38;2;251;125;28m')"
    "$(printf '\033[38;2;255;158;25m')"
    "$(printf '\033[38;2;255;178;25m')"
    "$(printf '\033[38;2;255;198;25m')"
    "$(printf '\033[38;2;200;195;57m')"
    "$(printf '\033[38;2;132;186;97m')"
    "$(printf '\033[38;2;73;173;133m')"
    "$(printf '\033[38;2;50;148;155m')"
    "$(printf '\033[38;2;28;123;178m')"
    "$(printf '\033[38;2;47;107;184m')"
    "$(printf '\033[38;2;95;98;179m')"
    "$(printf '\033[38;2;143;90;175m')"
)
GAY_GRADIENT=(
	""
	"$(printf '\033[38;2;239;42;42m')"
	"$(printf '\033[38;2;255;150;25m')"
	"$(printf '\033[38;2;255;203;25m')"
	"$(printf '\033[38;2;78;179;129m')"
	"$(printf '\033[38;2;19;113;187m')"
	"$(printf '\033[38;2;143;90;175m')"
)
TRANS_GRADIENT=(
	""
	"$(printf '\033[38;2;91;206;250m')"
	"$(printf '\033[38;2;245;169;184m')"
	"$(printf '\033[38;2;255;255;255m')"
	"$(printf '\033[38;2;245;169;184m')"
	"$(printf '\033[38;2;91;206;250m')"
)
BI_GRADIENT=(
    ""
    $RBLUE
    $RPURPLE
    $RPINK
)
RESET="$(printf '\033[0m')"
#BOLD=printf '\033[1m'


printf "%sB%sE %sG%sA%sY %sD%sO %sC%sR%sI%sM%sE%sS%s!\n\n" $RAINBOW14

#rainbow flag





TRANS_BLUE=(
    ""
    "$(printf '\033[0;30m\033[48;2;91;206;250m')"
    "$(printf '\033[0m')"
 )
TRANS_PINK=(
    ""
    "$(printf '\033[0;30m\033[48;2;245;169;184m')"
    "$(printf '\033[0m')"
)
TRANS_WHITE=(
    ""
    "$(printf '\033[0;30m\033[48;2;255;255;255m')"
    "$(printf '\033[0m')"
)




printf "%s        .        %s\n"$TRANS_BLUE
printf "%s  \_____)\\______ %s\n"$TRANS_PINK
printf "%s  //--v____ __\`< %s\n"$TRANS_WHITE
printf "%s          )/     %s\n"$TRANS_PINK
printf "%s -blahaj  '      %s\n"$TRANS_BLUE
printf '\n'

#printf "%s*%sB%sE%s*%sG%sA%sY%s*%sD%sO%s*%sC%sR%sI%sM%sE%sS%s*%s\n" $RAINBOW18 $RESET



TIME_COLOR="$(printf '\033[38;2;255;86;127m')"
DIR_COLOR="$(printf '\033[38;2;0;255;155m')"
GIT_COLOR="$(printf '\033[38;2;0;176;254m')"
TIP="❱"

local current_dir="%B%{$DIR_COLOR%}[%~]%{$reset_color%}"
# prompt ❱
# PROMPT='$(real_time) $(directory) $(git_status)$(command_status) ';
PROMPT='%B╭─$(real_time)${current_dir}$(git_status)
%B╰─%{$RBLUE%}$TIP%{$RPURPLE%}$TIP%{$RPINK%}$TIP%b '


