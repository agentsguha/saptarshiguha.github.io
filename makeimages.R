pattern <- "_*"
pattern <- "*jpg"
imges <- normalizePath(list.files(pattern=pattern,full=TRUE))
pct <- 1
mh <- 800
mw <- 800
library(data.table)
m <- lapply(imges, function(s){
    i1 <- system(sprintf("identify -verbose %s", s),inter=TRUE)
    hw <- as.numeric(strsplit(strsplit(tail(strsplit(i1[grepl("Geometry",i1)]," ")[[1]],1),"+",fixed=TRUE)[[1]][[1]],"x")[[1]])
    width <- hw[1];height=hw[2];
    aspect <- height/width
    if(width<=height*1e9){
        new.height <- pmin(pct*height, mh)
        new.width <- new.height/aspect
    }else{
        new.width <- pmin(pct*width, mw)
        new.height <- new.width*aspect
    }
    data.table(i = s,w=new.width,h=new.height)
})
m <- rbindlist(m)

PATH='dillon'

convert=FALSE
ii <- paste(unlist(lapply(1:nrow(m),function(i){
    l <- m[i,]
    if(convert) {
        conv <- sprintf("convert %s -resize %sx%s %s", l$i, as.integer(l$w), as.integer(l$h), gsub("DSC","t-", basename(l$i)))
        print(conv)
        system(conv)
    }
    sprintf('<div class="item" data-w="%s" data-h="%s">\n\t<div class="img"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/%s/%s"></div>\n</div>', as.integer(l$w), as.integer(l$h),  PATH,if(convert) gsub("DSC","t-", basename(l$i)) else basename(l$i))
})),collapse='\n')
cat(ii)
cat("\n")


