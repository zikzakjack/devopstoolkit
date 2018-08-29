git config --list
git config --global --edit
git config --global user.name zikzakjack
git config --global http.sslverify false
git config --global http.postBuffer 157286400
git config --global http.sslcainfo /opt/git/latest/bin/curl-ca-bundle.crt
git config --global core.longPaths true

git config user.name zikzakjack
git config user.email zikzakjack@company.com
git config svn.authorsfile /user/zikzakjack/SVN2GIT/Authors/_authors.txt

svn log -q https://svn.company.com/repo/ | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2"@company.com>"}' | sort -u > /user/zikzakjack/SVN2GIT/Authors/_authors.txt

ls -l /user/zikzakjack/SVN2GIT/authors/_authors.txt
ls -l /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar
ls -l /user/zikzakjack/SVN2GIT/

svn list https://svn.company.com/repo/project1/
svn list https://svn.company.com/repo/project1/branches/ 
svn list https://svn.company.com/repo/project1/tags/ 
svn list https://svn.company.com/repo/project1/ | sort
svn list https://svn.company.com/repo/project1/branches/ | sort | wc -l
svn list https://svn.company.com/repo/project1/tags/ | sort | wc -l
svn list https://svn.company.com/repo/project1/trunk/ | sort | wc -l

export JAVA_HOME=/opt/jdk/v1.8.0_92-64bit/
echo "JAVA_HOME => ${JAVA_HOME}"
${JAVA_HOME}/bin/java -version

cd /user/zikzakjack/SVN2GIT/
mkdir /user/zikzakjack/SVN2GIT/Project1
cd /user/zikzakjack/SVN2GIT/Project1
rm -rf *
rm -rf .git
ls -la
git svn init --stdlayout --no-minimize-url --no-metadata https://svn.company.com/repo/project1/
git svn init --stdlayout --no-minimize-url https://svn.company.com/repo/project1/
git config --list | sort
git config user.name zikzakjack
git config user.email zikzakjack@company.com
git config svn.authorsfile /user/zikzakjack/SVN2GIT/authors/_authors.txt
git config --list | sort
git svn fetch
git status
git status -s
git status -sb
git config --list | sort
git branch
git branch --all
git branch -a
git tag --list
git tag -l
git remote -v
git log --oneline
${JAVA_HOME}/bin/java -Dfile.encoding=utf-8 -jar /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar verify
${JAVA_HOME}/bin/java -Dfile.encoding=utf-8 -jar /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar sync-rebase
${JAVA_HOME}/bin/java -Dfile.encoding=utf-8 -jar /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar clean-git
${JAVA_HOME}/bin/java -Dfile.encoding=utf-8 -jar /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar clean-git | grep "refs/remotes" | sort
${JAVA_HOME}/bin/java -Dfile.encoding=utf-8 -jar /user/zikzakjack/SVN2GIT/lib/svn-migration-scripts.jar clean-git --force
git remote -v
git remote rm origin
git remote -v
git remote add origin zikzakjack@github.company.com:myorg/Project1.git
git remote set-url origin https://zikzakjack@github.company.com/myorg/Project1.git
git remote -v
git push -u origin --all
git push --tags
