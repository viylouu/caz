cd /media/storage/projects/langs/treesit-caz
tree-sitter generate
if [ $? -eq 1 ]; then exit 1; fi
gitty "[$(date '+%m-%d-%Y %I:%M:%S %p')] AUTO UPDATE via ./test.sh"
cd /home/viylouu/odin-tree-sitter
rm -r /media/storage/projects/langs/caz/parsers/caz
odin run build -- install-parser -name:caz -parser:https://github.com/viylouu/tree-sitter-caz -yes #-path:/media/storage/projects/langs/caz_test/parsers/caz -yes
mkdir /media/storage/projects/langs/caz/parsers/caz
mv parsers/caz/parser.a /media/storage/projects/langs/caz/parsers/caz/
mv parsers/caz/caz.odin /media/storage/projects/langs/caz/parsers/caz/
cd /media/storage/projects/langs/caz
#clear
cat examples/hello-world/main.caz
echo -e "\n\n"
odin build src -out:caz 
./caz "examples/hello-world/main.caz"
echo -e "\n\n"
cd /media/storage/projects/langs/treesit-caz
tree-sitter parse /media/storage/projects/langs/caz_test/examples/hello-world/main.caz
