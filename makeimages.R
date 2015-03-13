pattern <- "_*"
pattern <- "*jpg"
imges <- normalizePath(list.files(pattern=pattern,full=TRUE))
## PARAMS
pct <- 1
PATH='dcaws'


##
rowheight <- 600
rowwidth <- 600

large.width <- 1500
large.height <- 1500

## Code
library(data.table)
m <- lapply(imges, function(s){
    i1 <- system(sprintf("identify -verbose %s", s),inter=TRUE)
    hw <- as.numeric(strsplit(strsplit(tail(strsplit(i1[grepl("Geometry",i1)]," ")[[1]],1),"+",fixed=TRUE)[[1]][[1]],"x")[[1]])
    print(sprintf("%s w=%s h=%s", s, hw[1], hw[2]))
    width <- hw[1];height=hw[2];
    aspect <- height/width
    if(width<=height){
        ## a portrait photo
        new.height <- rowheight
        new.width <- new.height/aspect
        new.large.height <- large.height
        new.large.width <- new.large.height/aspect
    }else{
        new.width <- rowwidth
        new.height <- new.width*aspect
        new.large.width <- large.height
        new.large.height <- new.large.width*aspect
    }
    data.table(i = s,ow = width, oh=height,w=new.width,h=new.height,bw=new.large.width, bh=new.large.height)
})
m <- rbindlist(m)


convert=TRUE
ii <- sprintf("%s\n",paste(unlist(lapply(1:nrow(m),function(i){
    l <- m[i,]
    if(convert) {
        conv <- sprintf("convert %s -quality 100 -resize %sx%s %s", l$i, as.integer(l$bw), as.integer(l$bh), sprintf("t-%s",basename(l$i)))
        conv2 <- sprintf("convert %s -quality 100 -resize %sx%s %s", l$i, as.integer(l$w), as.integer(l$h), sprintf("st-%s",basename(l$i)))
        print(conv)
        print(conv2)
        system(conv);system(conv2)
    }
    sprintf('<div class="item" data-w="%s" data-h="%s">\n\t<div class="img"><a href="{{ site.url }}/images/photos/%s/%s"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/%s/%s"></a></div>\n</div>', as.integer(l$w), as.integer(l$h),  PATH,if(convert) sprintf("t-%s", basename(l$i)) else basename(l$i),PATH,if(convert) sprintf("st-%s", basename(l$i)) else basename(l$i))
})),collapse='\n'))
cat(ii)
cat("\n")


