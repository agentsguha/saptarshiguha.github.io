options(width=200)
pattern <- "_*"
pattern <- ".*jpg"
imges <- normalizePath(list.files(pattern=pattern,full=TRUE))
## PARAMS
pct <- 1
PATH='sibl'

##
rowheight <- 900
rowwidth <- 900
## rowheight <- 400
## rowwidth <- 400

large.height <- 1800
large.width <- 2880

## xpan  factor
xpan.fac <- 2
xpanWidth2Height <- 65/24

## set to true if the bigger links need to be converted to something a wee smaller
## usually required for DSC images (from the fuji) but not required for scans
## by default, DSC is true, everything else is FALSE
## but if this global variable is FALSE
convert=c(DSC=TRUE,ELSE=FALSE)

## Code
library(data.table)
addBorder <- TRUE
border <- c('pctWhiteOuter'="0%%x0%%", pxBlack="6", pctWhiteInner="0")
## http://www.imagemagick.org/script/command-line-options.php#border
if(addBorder){
    lapply(imges, function(s){
               sf = sprintf("convert %s -bordercolor white -border %s -bordercolor black -border %s -bordercolor white -border %s %s",
                              s,border['pctWhiteInner'],border['pxBlack'],border['pctWhiteOuter'], sprintf('"%s/bord-%s"',dirname(s),basename(s)))
               print(sf)               
               system(sf)
           })
    pattern <- "bord.*jpg"
    imges <- normalizePath(list.files(pattern=pattern,full=TRUE))
}
removeBord <- function(s){
    if(!addBorder) return(s)
    gsub("bord-","",s)
}
m <- lapply(imges, function(s){
                ## Add a border now if required and overwrite image ...
                
                i1 <- system(sprintf("identify -verbose '%s'", s),inter=TRUE)
                hw <- as.numeric(strsplit(strsplit(tail(strsplit(i1[grepl("Geometry",i1)]," ")[[1]],1),"+",fixed=TRUE)[[1]][[1]],"x")[[1]])
                print(sprintf("%s w=%s h=%s", s, hw[1], hw[2]))
                width <- hw[1];height=hw[2];
                aspect <- height/width
                useXPAN <- (aspect < 0.45) || (aspect >= 2.2)
                convertThis <- grepl("(DSC)", s)
                print(convertThis)
                if(width<=height){
                    ## a portrait photo
                    new.height <- min(rowheight*(useXPAN*xpan.fac+(1-useXPAN)*1), height)
                    new.width <- new.height/aspect
                    new.large.height <- if(convertThis) large.height else height
                    new.large.width <- new.large.height/aspect
                }else{
                    new.width <- min(rowwidth*(useXPAN*xpan.fac+(1-useXPAN)*1), width)
                    new.height <- new.width*aspect
                    new.large.width <- if(convertThis) large.width else width
                    new.large.height <- new.large.width*aspect
                }
                data.table(i = s,asp=aspect,ow = width, oh=height,w=new.width,h=new.height,bw=new.large.width, bh=new.large.height,convert=convertThis,useXPAN=useXPAN)
            })
m <- rbindlist(m)

## Run this code in the directory of the files!!!
ii <- sprintf("%s\n",paste(unlist(lapply(1:nrow(m),function(i){
    l <- m[i,]
    if(l$convert) {
        conv <- sprintf("convert '%s' -quality 100 -resize %sx%s '%s'", removeBord(l$i), as.integer(l$bw), as.integer(l$bh), sprintf("t-%s",removeBord(basename(l$i))))
    }else {
        conv <- sprintf("cp '%s' './%s'",removeBord(l$i),  sprintf("t-%s",removeBord(basename(l$i))))
    }
    conv2 <- sprintf("convert '%s' -quality 100 -resize %sx%s '%s'", l$i, as.integer(l$w), as.integer(l$h), sprintf("st-%s",basename(l$i)))
    print(conv)
    print(conv2)
    system(conv);system(conv2)
    sprintf('<div class="item" data-w="%s" data-h="%s">\n\t<div class="img"><a href="{{ site.url }}/images/photos/%s/%s"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/%s/%s"></a></div>\n</div>', 
        as.integer(l$w), as.integer(l$h),  PATH,sprintf("t-%s", removeBord(basename(l$i))),PATH,sprintf("st-%s", basename(l$i)))
})),collapse='\n'))

cat(ii)
cat("\n")


