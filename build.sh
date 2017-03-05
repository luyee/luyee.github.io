##################################################################
#
# 此文件用来重新生成网站，提交至本地Git仓库。
# 注意！所有的提交都在jekyll_beta分支上。
# 而且，并没有推送至Github上。要部署至Github需要运行deploy.sh。
#
# 命令格式如下：
#
# 	sh build.sh <discription>
#
# 需要一个参数<discription>，用来简短描述此次提交的修改项。
# 注意，描述语句中间不能有空格。
#
##################################################################


# 生成所有categories页面
javac -d /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/bin/ /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/src/CategoriesPageGenerator.java
java -classpath /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/bin/ com.ciaoshen.blog.CategoriesPageGenerator

# 生成所有tag页面
javac -d /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/bin/ /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/src/TagsPageGenerator.java
java -classpath /Users/Wei/github/ciaoshen/java/com/ciaoshen/blog/bin/ com.ciaoshen.blog.TagsPageGenerator

# 重新生成_site
jekyll build

# 提交至本地Git仓库
# $1: 更新描述，比如增加了哪篇文章
git checkout jekyll_beta
git add .
git commit -m $1
