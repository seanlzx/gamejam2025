project_dir=".."


clear && clear

sed -n '/\[autoload\]/,/\[.*\]/p' "${project_dir}/project.godot" | while read line; do
	if [[ $line == *res* ]]; then
		echo $line
		file2=$(echo $line | sed -E 's#.*res://##g' | sed -E 's#(\.gd).*#\1#g')
		ls -l --color "${project_dir}/${file2}"
	fi
done

while read -r line; do
	file1=$(echo $line | sed 's#:.*##g')
	file2=$(echo $line | sed -E 's#.*res://##g' | sed -E 's#(\.gd|\.tscn).*#\1#g')
	if [[ "$file1" != "$prev" ]]; then
		echo
		echo $file1 contains below abs paths
	fi
	ls -l --color "${project_dir}/${file2}"
	prev="$file1"
	
done < <(grep --include '*.gd' -Ria "res:" "${project_dir}")
