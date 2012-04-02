# Requires less >= 1.3.0
#   npm install less -g

all: css/style.css

css/style.css: less/style.less
	lessc --compress less/style.less > css/style.css
