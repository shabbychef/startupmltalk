


.PHONY   : help 
.PHONY   : slidify view

help:  ## generate this help message
	@grep -P '^(([^\s]+\s+)*([^\s]+))\s*:.*?##\s*.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

index.html : %.html : %.Rmd
	r -l slidify -e 'slidify::slidify("$<");'

notes.html : %.html : %.md
	pandoc -f markdown_strict -t html -o $@ $<

slidify : index.html ## slidify from Rmarkdown source

%.view : %.html
	xdg-open file://$$(pwd)/$<

view : index.view ## view the slides in a (new) browser window

publish : index.html ## publish?
	r -l slidify -e 'publish(user="shabbychef", repo="startupmltalk", host="github")'


