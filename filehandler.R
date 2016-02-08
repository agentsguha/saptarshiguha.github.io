library(infuser)
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
getImgInfo <- function(dims){
    portrait <- dims['w']<dims['h']
    aspect <- dims['h']/dims['w']
    xpan <- (aspect < 0.45) || (aspect >= 2.2)
    list(portrait = as.numeric(portrait), aspect=as.numeric(aspect), xpan=xpan)
}
treatImage <- function(s,
                       dims,
                       thumdims,
                       downdims,
                       destfolder = "outs/",
                       convert = if(grepl("^(DSC)",basename(s))) TRUE else FALSE,
                       border = NULL,
                       xpan.fac = 2,verbose=TRUE){
    ## this will convert  to the newdims
    ## and if convert is TRUE will also resize the image to the larger size too
    ## this larger size is used for downloads (essentially film scanners stay the same
    ## and digital Fuji's get resized)
    imgInfo <- getImgInfo(dims)
    s <- normalizePath(path.expand(s))
    t <- tempfile()
    if(imgInfo$portrait){
        thum.height <- min(thumdims['h']*(imgInfo$xpan*xpan.fac+(1-imgInfo$xpan)*1), dims['h'])
        thum.width <- thum.height/imgInfo$aspect
        down.height <- if(convert) downdims['h'] else dims['h']
        down.width <- down.height/imgInfo$aspect
    }else{
        thum.width <- min(thumdims['w']*(imgInfo$xpan*xpan.fac+(1-imgInfo$xpan)*1), dims['w'])
        thum.height <- thum.width*imgInfo$aspect
        down.width <- if(convert) downdims['w'] else dims['w']
        down.height <- down.width*imgInfo$aspect
    }
    if(!is.null(border)){
        thum <- infuse("convert '{{srcname}}' {{string}}  -quality 100 -resize {{width}}x{{height}} '{{dest}}'"
                     , srcname=s, width=thum.width, height=thum.height
                     , string=border,dest=(sprintf("%s/thum-%s", destfolder, basename(s))))
    }else{
        thum <- infuse("convert '{{srcname}}' -quality 100 -resize {{width}}x{{height}} '{{dest}}'",
                       srcname=s, width=thum.width, height=thum.height
                     , dest=sprintf("%s/thum-%s", destfolder, basename(s)))
    }
    if(convert){
        dwn <- infuse("convert '{{srcname}}' -quality 100 -resize {{width}}x{{height} '{{dest}}'",
                      srcname=s, width=down.width, height=down.height
                    , dest=sprintf("%sdown-%s", destfolder, basename(s)))
    }else{
        dwn <- infuse("cp '{{srcname}}' '{{dest}}'",srcname=s
                    , dest=sprintf("%sdown-%s", destfolder, basename(s)))
    }
    if(verbose) { print(sprintf("%s and ",dwn));system(dwn)}
    if(verbose) { print(thum);system(thum)}
    return(list(w=thum.width, h=thum.height,thum=sprintf("thum-%s", basename(s)),dest=sprintf("down-%s", basename(s))))
}

produceHTML <- function(o, p){
    h <- list()
    for(x in o){
        y <- '<div class="item" data-w="{{w}}" data-h="{{h}}">\n\t<div class="img"><a href="[[ site.url ]]/images/photos/{{p}}/{{thum}}"><img src="{{ site.url }}/images/blank.gif" data-src="[[ site.url ]]/images/photos/{{p}}/{{down}}"></a></div>\n</div>'
        x$p <- p;x$down <-x$dest
        y <- gsub("\\[\\[","{{",infuse(y, x)); y <- gsub("\\]\\]","}}",y)
        h[[length(h)+1]] <- y
    }
    y <- sprintf("%s\n",(paste(unlist(h),collapse="\n")))
    clip <- pipe("pbcopy", "w") ; writeLines(y, con=clip); close(clip)
    y
}
        
######################################################################
## border strings
######################################################################
WhiteBlackBorder1 <- "-bordercolor white -border 5 -bordercolor black -border 10 -bordercolor white -border 5"
White10BlackBorder5 <- "-bordercolor white -border 10 -bordercolor black -border 5 -bordercolor white -border 5"
BlackWhiteBorder5 <- "-bordercolor black -border 10 -bordercolor white -border 5"
xpanToBlackBorder110 <-  "-background black  -gravity north -splice 0x110 -gravity south -splice 0x110"
polaroid <- "-bordercolor black -border 5x5  -background white  -gravity north -splice 0x40  -gravity south -splice 0x130 -gravity east -splice 20x0 -gravity west -splice 20x0   -gravity south  -bordercolor grey -border 5x5"
polaroidth <- "-bordercolor black -border 10x10  -background white  -gravity north -splice 0x40  -gravity south -splice 0x130 -gravity east -splice 20x0 -gravity west -splice 20x0   -gravity south  -bordercolor grey -border 5x5"

######################################################################
## options
######################################################################
rowheight <- 750
rowwidth <- 750
down.height <- 1800
down.width <- 2880
xpan.fac <- 2
destf <- "outs/"
htmout <- ""

imges <- normalizePath(list.files(pattern="*.jpg",full=TRUE))
if(dir.exists(destf)){
    warning(sprintf("Deleting everything inside %s", normalizePath(path.expand(destf))))
    system(sprintf("rm -rf %s/*", destf))
}else{
    dir.create(destf)
}

library(progress)
pb <- progress_bar$new(format = "processing :what [:bar] :percent (:current / :total) elapsed: :elapsed eta: :eta"
                      ,total = length(imges), clear = FALSE, width= 80)
o <- list()
for(i in imges){
    pb$tick(tokens=list(what=i))
    o[[ length(o)+1 ]] <- treatImage(s=i , dims     = getImageDims(i) , thumdims = c(w=rowwidth,h=rowheight)
                                   , downdims = c(w=down.width, h=down.height)
                                   , destfolder = destf
                                   , border=xpanToBlackBorder110,verbose=FALSE)
}
produceHTML(o,"foo")


           
