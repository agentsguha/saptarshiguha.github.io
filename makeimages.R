options(width=200)
pattern <- "_*"
pattern <- "*jpg"
imges <- normalizePath(list.files(pattern=pattern,full=TRUE))
## PARAMS
pct <- 1
PATH='xpanAndvisitors'


##
rowheight <- 400
rowwidth <- 400

large.width <- 1500
large.height <- 1500

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
m <- lapply(imges, function(s){
    i1 <- system(sprintf("identify -verbose %s", s),inter=TRUE)
    hw <- as.numeric(strsplit(strsplit(tail(strsplit(i1[grepl("Geometry",i1)]," ")[[1]],1),"+",fixed=TRUE)[[1]][[1]],"x")[[1]])
    print(sprintf("%s w=%s h=%s", s, hw[1], hw[2]))
    width <- hw[1];height=hw[2];
    aspect <- height/width
    useXPAN <- (aspect < 0.45) || (aspect >= 2.2)
    convertThis <- grepl("^(DSC)", s)
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
        conv <- sprintf("convert %s -quality 100 -resize %sx%s %s", l$i, as.integer(l$bw), as.integer(l$bh), sprintf("t-%s",basename(l$i)))
    }else {
        conv <- sprintf("cp %s ./%s",l$i,  sprintf("t-%s",basename(l$i)))
    }
    conv2 <- sprintf("convert %s -quality 100 -resize %sx%s %s", l$i, as.integer(l$w), as.integer(l$h), sprintf("st-%s",basename(l$i)))
    print(conv)
    print(conv2)
    system(conv);system(conv2)
    sprintf('<div class="item" data-w="%s" data-h="%s">\n\t<div class="img"><a href="{{ site.url }}/images/photos/%s/%s"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/%s/%s"></a></div>\n</div>', as.integer(l$w), as.integer(l$h),  PATH,sprintf("t-%s", basename(l$i)),PATH,sprintf("st-%s", basename(l$i)))
})),collapse='\n'))

cat(ii)
cat("\n")




y <- rhwatch(map=function(a,b){
    seconds <- round(runif(1)*3600,0)
    rhcollect(1,c(1,seconds, seconds/3600))
}, reduce=rhoptions()$temp$colsummer, input=c(1e9,10000,100))
    
