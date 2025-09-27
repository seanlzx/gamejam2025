tmux_session_name="tmux_encephalon_monitor_1"

function help_func(){
	echo "Usage: "
	echo "   ./$0 start all_panes|alt_panes"	
	echo "   ./$0 stop" 
	echo ""
	echo " - all_panes TODO"
	echo "    - display all monitoring panes configured, window 1 for group 1, window 2 for group 2"
	echo " - alt_panes TODO"
	echo "    - display 4 panes, alternate monitoring in 30s intervals"
}

if [[ $1 =~ ^(-h|--help)$ ]]; then
	help_func
	exit 1
fi

if [[ "$1" =~ ^stop$ ]]; then
	tmux kill-session -t "$tmux_session_name"
	tmux ls
	exit 0
fi

# don't check for stop here, as stop is checked for above
if [[ ! "$1" =~ ^start$ ]]; then
	echo "invalid first argument"
	help_func
	exit 1
fi


if [[ ! "$2" =~ ^(all_panes|alt_panes)$ ]]; then
	echo "invalid second argument"
	help_func
	exit 1
fi


# Exit if tmux session already exists
tmux has-session -t "$tmux_session_name" 2>/dev/null
if [ $? -eq 0 ]; then
	echo "$tmux_session_name is already running do you wish to attach session [Yy|Nn]"
	tmux ls

	read -r input

	if grep -e y -e Y <(echo "$input") > /dev/null; then
		tmux attach -t "$tmux_session_name"
		exit 0
	elif grep -e n -e N <(echo "$input") > /dev/null; then
		exit 0
	else
		echo invalid input
	fi
		 
		
	tmux attach -t "$tmux_session_name"
	exit 0
fi

tmux new-session -d -s "$tmux_session_name"
tmux ls

tmux split-window -h -t ${tmux_session_name}
tmux split-window -h -t ${tmux_session_name}
tmux split-window -h -t ${tmux_session_name}

tmux send-keys -t "${tmux_session_name}:0.0" '"/mnt/c/Program Files/Git/bin/bash.exe" --login -i' C-m
tmux send-keys -t "${tmux_session_name}:0.0" 'cd "$HOME/AppData/Roaming/Godot/app_userdata/Encephalon/" && tail -F logs/godot.log' C-m
tmux send-keys -t "${tmux_session_name}:0.1" "while true; do clear; ./tree_gd.sh; sleep 15; ./tree_tscn.sh; sleep 15; done" C-m
tmux send-keys -t "${tmux_session_name}:0.2" "while true; do clear; ./verify_absolutes_and_singletons.sh; sleep 15; ./tree.sh ; sleep 5; done" C-m
tmux send-keys -t "${tmux_session_name}:0.3" "while true; do clear; ./check_todos_notes.sh ; sleep 15 ;done" C-m

tmux select-layout -t ${tmux_session_name} even-horizontal

# for some reason pane rename won't occur unless alittle sleep
sleep 2

# it's important that pane rename is done after commands are sent to the pane
tmux select-pane -t "${tmux_session_name}:0.0" -T tail_and_git
tmux select-pane -t "${tmux_session_name}:0.1" -T gd_and_tscn_tree
tmux select-pane -t "${tmux_session_name}:0.2" -T path_integrity_and_full_tree
tmux select-pane -t "${tmux_session_name}:0.3" -T todos_and_notes

# this only prevent window renames
tmux set-option -t "${tmux_session_name}" allow-rename off
tmux set-option -t "${tmux_session_name}" automatic-rename off

## this should prevent pane renames, still doesn't work
#tmux set-option -t "${tmux_session_name}" set-titles off
## this also doesn't work
#tmux send-keys -t "${tmux_session_name}:0.0" "PROMPT_COMMAND=':'" C-m
#tmux send-keys -t "${tmux_session_name}:0.1" "PROMPT_COMMAND=':'" C-m
#tmux send-keys -t "${tmux_session_name}:0.2" "PROMPT_COMMAND=':'" C-m
#tmux send-keys -t "${tmux_session_name}:0.3" "PROMPT_COMMAND=':'" C-m

# uh yeah this is suppose to run last, it's a process, nothing will run after this unless it's detach/killed stupid. 
tmux attach-session -t $tmux_session_name

