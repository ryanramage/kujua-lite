all: css/style.css

css/style.css: less/style.less
	lessc --compress less/style.less > css/style.css
