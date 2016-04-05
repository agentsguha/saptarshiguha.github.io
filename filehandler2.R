library(infuser)
library(colorout)
library(data.table)
options(width=250)

makePB <- function(l){
    require(progress)
    progress_bar$new(format = "Processing (:extra) [:bar] :percent (:current / :total) elapsed: :elapsed eta: :eta"
                          ,total = l, clear = FALSE, width= 60)
}

getImageDims <- function(s){
    structure(
        as.numeric(
            strsplit(
                gsub("Size: ","",
                     system(
                         sprintf('convert %s -print "Size: %%wx%%h\n" /dev/null',s)
                        ,intern=TRUE))
               ,"x")[[1]])
       ,names=c("w","h"))
}

RM <- function(s){
    print(s)
    strsplit(s,"&export=download")[[1]][[1]]
}


## Store your pictures in a folder in gdrive e.g.  webimages/photos/idleaway
## Wait for them to upload
## Edit imageFileRep.py  and set 'bp' to the name of the folder (idleaway)
## run the code which will save filenames to "/tmp/images.csv"
## switch to the folder  webimages/photos/idleaway
## and run the following code


pat <- "/tmp/images.csv"
files <- fread(pat)
files[, prefix:= unlist(lapply(strsplit(title,"-"),"[[",1))]
files[, sizetype:= sapply(title, function(s) if(grepl("-brd", s)) "brd" else "full")]

## pb <- makePB(nrow(files))
## files <- files[, {
##     ## pb$tick(token=list(extra=title))
##     fullname <- normalizePath(sprintf("./%s",title))
##     dims <- getImageDims(fullname)
##     cbind(.SD, data.table(w = dims['w'], h=dims['h']))
## },by=url]

newurls <- files[,{
     y <- '<div class="item" data-w="{{w}}" data-h="{{h}}">\n\t<div class="img"><a href="{{fullglink}}"><img src="{{ site.url }}/images/blank.gif" data-src="{{smallglink}}"></a></div>\n</div>'
     yt <- infuse(y, list(w=w[ sizetype =="brd"],
                          h=h[sizetype=="brd"],
                          site.url = "{{ site.url }}",
                          fullglink=RM(url[sizetype %in% c('full','sml')]),
                          smallglink=RM(url[sizetype=="brd"])))
     list(newurl=yt)
},by=prefix]
y <- sprintf("%s\n",paste(newurls$newurl,collapse="\n"))
clip <- pipe("pbcopy", "w") ; writeLines(y, con=clip); close(clip)
y


