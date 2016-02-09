library(infuser)
library(colorout)

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
getThumSizes <- function(imgInfo,thumdims,origdims){
    if(imgInfo$portrait){
        thum.height <- min(thumdims['h']*(imgInfo$xpan*xpan.fac+(1-imgInfo$xpan)*1), origdims['h'])
        thum.width <- thum.height/imgInfo$aspect
    }else    {
        thum.width <- min(thumdims['w']*(imgInfo$xpan*xpan.fac+(1-imgInfo$xpan)*1), origdims['w'])
        thum.height <- thum.width*imgInfo$aspect
    }
    return(list(w=thum.width, h=thum.height))
}
getDownSizes <- function(imgInfo,downdims,origdims,convert=TRUE){
    if(imgInfo$portrait){
        down.height <- if(convert) downdims['h'] else origdims['h']
        down.width <- down.height/imgInfo$aspect
    }else    {
        down.width <- if(convert) downdims['w'] else origdims['w']
        down.height <- down.width*imgInfo$aspect
    }
    return(list(w=down.width, h=down.height))
}
treatImage <- function(os,
                       thumdims,
                       downdims,
                       destfolder = "outs/",
                       convert = if(grepl("^(DSC)",basename(os))) TRUE else FALSE,
                       border = NULL,
                       xpan.fac = 2,verbose=TRUE){
    ## this will convert  to the newdims
    ## and if convert is TRUE will also resize the image to the larger size too
    ## this larger size is used for downloads (essentially film scanners stay the same
    ## and digital Fuji's get resized)
    ## Do borders first - they change aspect image
    os <- normalizePath(path.expand(os))
    origdims <- getImageDims(os)
    imgInfo <-  getImgInfo(origdims)
    ######################################################################
    ## Make Thumbnails
    ######################################################################
    thumsz <- getThumSizes(imgInfo,thumdims,origdims)
    thum <- infuse("convert '{{srcname}}' -quality 100 -resize {{width}}x{{height}} '{{dest}}'",
                   srcname=os, width=thumsz$w, height=thumsz$h
                 , dest=sprintf("%s/thum-%s", destfolder, basename(os)))
    if(verbose) { print(thum)}
    system(thum)
    ######################################################################
    ## If we need to convert now is the time (but this is download
    ## conversion, no need to download the entire humungous image. So
    ## we need to resample the image according to the _original_
    ## dimensions.
    if(convert){
        downsz <- getDownSizes(imgInfo,downdims ,origdims)
        dwn <- infuse("convert '{{srcname}}' -quality 100 -resize {{width}}x{{height} '{{dest}}'",
                      srcname=os, width=downsz$w, height=downsz$h
                    , dest=sprintf("%sdown-%s", destfolder, basename(os)))
    }else{
        dwn <- infuse("cp '{{srcname}}' '{{dest}}'",srcname=os
                    , dest=sprintf("%sdown-%s", destfolder, basename(os)))
    }
    if(verbose) { print(dwn)}
    system(dwn)
    ######################################################################
    ## Add a border if required, and output sizes are of this bordered
    ## image
######################################################################
    if(!is.null(border)){
        brds <- infuse("convert '{{srcname}}' {{string}} -quality 100  '{{dest}}'"
                     , srcname=sprintf("%s/thum-%s", destfolder, basename(os)), 
                     , string=border,dest=sprintf("%s/thum-%s", destfolder, basename(os)))
        if(verbose) print(brds)
        system(brds)
        finalsz <- getImageDims(normalizePath(path.expand(sprintf("%s/thum-%s", destfolder, basename(os)))))
        finalsz <- list(w=finalsz['w'], h=finalsz['h'])
    }else finalsz <- imgInfo
    return(list(w=finalsz$w, h=finalsz$h,thum=sprintf("thum-%s", basename(os)),down=sprintf("down-%s", basename(os))))
}
produceHTML <- function(o, p){
    h <- list()
    for(x in o){
        y <- '<div class="item" data-w="{{w}}" data-h="{{h}}">\n\t<div class="img"><a href="[[ site.url ]]/images/photos/{{p}}/{{down}}"><img src="{{ site.url }}/images/blank.gif" data-src="[[ site.url ]]/images/photos/{{p}}/{{thum}}"></a></div>\n</div>'
        x$p <- p;
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
xpanToBlackAndWhiteSpacing110 <-  "-background black   -gravity north -splice 0x110 -gravity south -splice 0x110 -background white  -gravity north -splice 0x10  -gravity south -splice 0x50"
whiteOnTop <-  "-background white  -gravity north -splice 0x50  -gravity south -splice 0x50"
thickWhiteBorder <-  "-bordercolor white -border 150 "
thickWhiteTopBorder <-  "-background white  -gravity north -splice 0x120  -gravity south -splice 0x120"
polaroid <- "-bordercolor black -border 5x5  -background white  -gravity north -splice 0x40  -gravity south -splice 0x130 -gravity east -splice 20x0 -gravity west -splice 20x0   -gravity south  -bordercolor grey -border 5x5"
polaroidth <- "-bordercolor black -border 10x10  -background white  -gravity north -splice 0x40  -gravity south -splice 0x130 -gravity east -splice 20x0 -gravity west -splice 20x0   -gravity south  -bordercolor grey -border 5x5"
######################################################################
## options
######################################################################
rowheight <- 1000
rowwidth <- 1000
down.height <- 1800
down.width <- 2880
xpan.fac <- 2
destf <- "outs/"
htmlout <- "sfwet"
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

J <- sapply(imges,function(k) if(nchar(basename(k))>10) thickWhiteTopBorder else xpanToBlackAndWhiteSpacing110)
for(idx in seq_along(imges)){
    i <- imges[[idx]]
    pb$tick(tokens=list(what=i))
    o[[ length(o)+1 ]] <- treatImage(os=i, thumdims = c(w=rowwidth,h=rowheight)
                                   , downdims = c(w=down.width, h=down.height)
                                   , destfolder = destf
                                   , border=J[idx],verbose=FALSE)
}
produceHTML(o,htmlout)
