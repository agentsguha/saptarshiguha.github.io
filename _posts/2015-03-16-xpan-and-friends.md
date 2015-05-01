---
layout: post
title: The Interesting XPan and Even More Interesting Friends, also, Quantiles and Discrete Distributions
excerpt: A panoramic view of the city though friends eyes ...
tags: 35mm, xpan, panorama, percentiles
---

{{ page.title }}
================
<div class="pdate"> {{ page.date | date: "%b %d, %Y" }} </div>

Some math. We have some data $m_1,m_2,m_3,\ldots, m_n$ that are $iid$
$F$. Suppose $x_1,x_2,\ldots, x_k$ are the _unique_ $k$ quantiles of the
data. Note that $k \le n$ because if the data is discrete in some regions of
$F$, the quantiles might be the same. I use the word quantiles but actually
mean the values $x_i = argmin_x P(X \le x) \ge k/M = F_n^{-1}(k/M)$ where $M$
could 100,1000, 2000 etc.

Then define $S = \{ 0,1,2,\ldots, M\}$ and $x^*_i = \\{s \in S: x_i =
F_n^{-1}(s/M)\\}$. Let's take an example.

## Sample from Continuous Data
Consider

    x = runif(100)

then the 10 unique quantiles corresponding to $1/10,\ldots,10/10$ are given by
`unique(quantile(x))` which for this case is going to be `quantile(x)`. They are
all unique. If $x_1$ be the first quantile (corresponding to $1/10$) then $x^*_1
= \\{ 1 \\}$.

## Sample from  Discrete Data
Consider the following data (R code)

    x = sample(c(1,2,3),100, replace=TRUE)

Then, the unique quantiles are `unique(quantile(x,1:10/10))` which is

    [1] 1 2 3

and then

<div>
\begin{align*}
x^*_1 &= \{s \in 1\ldots 10 :  x_1 = F^{-1}_n( s/10) \} =  \{1,2,3\} \\ 
x^*_2 &= \{s \in 1\ldots 10 :  x_2 = F^{-1}_n( s/10) \} =  \{4,5,6\} \\ 
x^*_3 &= \{s \in 1\ldots 10 :  x_3 = F^{-1}_n( s/10) \} =  \{7,8,9,10\} 
\end{align*}
</div>

So what is this all about? Consider a sample from the Normal(0,1) distribution,
and compute it's ECDF $F_n$, then given another sample $Y$ from the Normal(0,1)
distribution, $F_n(Y)$ is going to be uniformly distributed on $[0,1]$. Hence
the average of this is going to be 0.5. By comparing the expectations of
$E(F_n(Y'))$ for different distributions we can compare them to the baseline
distribution i.e. Normal(0,1) (in this case). Technically, the theorem is not a
n&s one, so to be precise if the expectation is not half, then $Y'$ is not
distributed as $F$, but if the expectation is half, well, it doesn't imply that
$Y'$ is distributed as $F$.

It is equivalent to use the indices in the set S (defined above) as opposed the
probabilities from $F_n$. But how do we handle the discrete case (which will
have duplicates in the quantiles)?

## Implementation

Once again, consider the unique quantiles $x_1,x_2,\ldots,x_k$ and add to it
$x_0 = -\infty$ and $x_{k+1}=\infty$. Then let
$G=$ `findInterval(.,all.inside=TRUE)` where $\text{findInterval}$ is the
R function.

<div>
\begin{align}
G(y,\{x_0,x_1,\ldots,x_{k+1}\}) = j+1 \qquad x_j \le y \lt x_{j+1} 
\end{align}
</div>

and 

<div>
\begin{align*}
I(y) = \text{Discrete Uniform Sample of Size 1 from } x^*_{G(y) - 1 }
\end{align*}
</div>

<div>
and $x^*_0$ is the set containing only 0. Also observe $\cup_{i=1}^k x^*_i = \{1,2,\ldots,M\}$ .
So consider again the continuous distribution: take a sample, compute the unique quantiles $x_i$ and the sets $x^*_i$ . Note, that
$|x^*_i| = 1$.If we apply $I$ to a new sample $y_j$ from the same distribution,
we will obtain roughly a uniform distribution on  the numbers $1,2,\ldots, M$.
Consider the discrete case, for which the cardinality of some of the $x^*_i$ is greater than
1. In this case we randomly sample from the set $I(y_j)$, so if the sample size of
$y$ is very large, we will be uniformly sampling across $\\{1,2,\ldots, M\\}$.
If the distribution of $y$ is say to the right of $x$, then the distribution of
the $I(y)$'s will be correspondingly shifted right. If there are some $y$'s
which are less than $\min x$ we will have a lot of zeroes and the distribution
of $I(y)$ will be shifted left.
</div>

## But why ...

At Mozilla, we have a slew of measurments, see
[this website](http://mxr.mozilla.org/mozilla-central/source/toolkit/components/telemetry/Histograms.json).
I was asked to create some indices of the `CYCLE_COLLECTOR*` measures. Index
creation is varied and one method I haven't seen is comparing the data of a new
population to the distribution of a reference population using the above
method. The typical methods are based on normalization and essentially comparing
on the standard deviation scale. Using the index method, i need not worry about
outliers, or the shape of the distributions. The approach i'm thinking of involves

- take a reference population, say WINNT, 32 bit, Firefox v35 (A)
- compute the unique quantiles of `CYCLE_COLLECTOR_COLLECTED` (for example)
- use the above method to compute $I(y)$ for the `CYCLE_COLLECTOR_COLLECTED` data from another population (B)
- and use some summary statistic to compare $I(y)$ for the data for B with the
$I(y)$ for A ( applying $I$ to the data for A will result in a uniform
distribution)

That is just for one measure, i need a way to combine all the `CYCLE_COLLECTOR*`
measures into one `CYCLE_COLLECTION` index.

## Code
    p.assign.bucket <- function(xp, M){
         ## xp is a vector of numbers
         ## xp can be data table, in which case 'x' are the values of X and
         ## 'n' is their frequency
         x                 <- as.numeric(c(-Inf,if(is(xp,"data.table"))
             xp[,wtd.quantile(x,n, 1:M/M)]
         else
             quantile(xp, 1:(M)),Inf))
         xu                <- sort(unique(x))
         xt                <- format(x, trim=TRUE,nsmall=20)
         xstar             <- split(1:(M+2), xt)
         xstar             <- xstar[order(as.numeric(names(xstar)))]
         allcont           <- all( unlist(lapply(xstar, length))==1)
         structure(
             if(allcont)
                 function(y,...)
                     findInterval(y,xu,all.inside=TRUE) -1
             else
                 function(y,bk=FALSE) {
                     X     <- findInterval(y, xu,all.inside=TRUE,rightmost.closed=TRUE)
                     if(bk) return(X)
                     sapply(X, function(yp)  {
                         z <- xstar[[ yp ]]-1
                         if(length(z)==1) z else sample(z,1)
                     })}
           , src = x, xstar=xstar)

     xp                    <- sample(c(1,2), 4000,replace=TRUE)
     h                     <- pmethod(xp,10)
     yp                    <- sample(c(1,2), 40000,replace=TRUE)
     yps                   <- h(yp)
     round(prop.table(table(yps))*100,1)
}


## Future Work
The above assumes we have at least two distinct $x_i$ apart from $\infty$ and $-\infty$.
Compute standard errors for what ever summary statistic I use in the above steps.


# Photos

As always, I like to leave people with photos.  The photos below were
taken with an XPan using Kodak 800 and TriX-400. The square pictures were with a
hasselblad on Portra 160(?, could be 400).  On the whole I'm quite a fan of
Photoworks, San Francisco. Their scan quality is very good though slightly
overpriced. Now does that mean i lose myself down the rabbit hole of flatbed
scanning? Well, not exactly, I've gone and gotten myself a Pakon scanner. Which
thankfully is not such a rabbit hole as i might have thought. More on that
later.


<div class="row" style="margin-top:0.5em;">

<div class="col-xs-3" style="padding-right:0;margin-right:0;">
<div id="demo2" class="flex-images" >

<div class="item" data-w="292" data-h="800" style="float:right;">
   <div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740018_a1.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740018_a1.jpg"></a></div>
</div>
</div>
</div>
<script>
$('#demo2').flexImages({ rowHeight:600 , truncate: 0});
</script>


<div class="col-xs-9">
<div id="demo1" class="flex-images">

<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-001.25810002.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-001.25810002.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="876">
  <div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-002.25810003.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-002.25810003.jpg"></a></div>
</div>

</div></div>
</div>
<script>
$('#demo1').flexImages({ rowHeight:400 , truncate: 0});
</script>



<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo3" class="flex-images" >

<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-003.25810004.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-003.25810004.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-004.25810009.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-004.25810009.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-005.25810011.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-005.25810011.jpg"></a></div>
</div>

</div></div></div>
<script>
$('#demo3').flexImages({ rowHeight:600 , truncate: 0});
</script>


Hasselblad photos compete with looking through the ground glass. Sometimes the
view the glass is in fact better than the photo. Sometimes( well mostly because
of my poor skills), the photo is better than the ground glass.



<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo4" class="flex-images" >

<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-006.000049380002.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-006.000049380002.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-007.000049380003.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-007.000049380003.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-008.000049380004.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-008.000049380004.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-009.000049380006.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-009.000049380006.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-010.000049380007.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-010.000049380007.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-011.000049380010.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-011.000049380010.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-012.000049380011.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-012.000049380011.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-013.000049390002.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-013.000049390002.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-014.000049390003.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-014.000049390003.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-015.000049390004.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-015.000049390004.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-016.000049390007.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-016.000049390007.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-017.000049390010.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-017.000049390010.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="1182">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-018.000049390011.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-018.000049390011.jpg"></a></div>
</div>

</div></div></div>
<script>
$('#demo4').flexImages({ rowHeight:600 , truncate: 0});
</script>


<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo5" class="flex-images" >
<div class="item" data-w="530" data-h="800">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740004.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740004.jpg"></a></div>
</div>
<div class="item" data-w="530" data-h="800">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740006.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740006.jpg"></a></div>
</div>
<div class="item" data-w="530" data-h="800">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740008.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740008.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="796">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740012.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740012.jpg"></a></div>
</div>
<div class="item" data-w="530" data-h="800">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740013.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740013.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="795">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740015.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740015.jpg"></a></div>
</div>
<div class="item" data-w="530" data-h="800">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740014.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740014.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="795">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740018_a.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740018_a.jpg"></a></div>
</div>
</div></div></div>
<script>
$('#demo5').flexImages({ rowHeight:795 , truncate: 0});
</script>



<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo6" class="flex-images" >
<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740018_a2.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740018_a2.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="876">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740018_a3.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740018_a3.jpg"></a></div>
</div>
</div></div></div>
<script>
$('#demo6').flexImages({ rowHeight:600 , truncate: 0});
</script>



<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo7" class="flex-images" >

<div class="item" data-w="265" data-h="400">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740021.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740021.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="795">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740023.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740023.jpg"></a></div>
</div>
<div class="item" data-w="265" data-h="400">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740027.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740027.jpg"></a></div>
</div>
<div class="item" data-w="265" data-h="400">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740028.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740028.jpg"></a></div>
</div>
<div class="item" data-w="265" data-h="400">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740034.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740034.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="795">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53740029.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53740029.jpg"></a></div>
</div>
</div></div></div>
<script>
$('#demo7').flexImages({ rowHeight:795 , truncate: 0});
</script>



<div class="row" style="margin-top:0.5em;">
<div class="col-xs-12" style="padding-right:0;margin-right:0;">
<div id="demo8" class="flex-images" >
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750001.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750001.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750003.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750003.jpg"></a></div>
</div>
<div class="item" data-w="2341" data-h="959">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750005.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750005.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750006.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750006.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750008.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750008.jpg"></a></div>
</div>
<div class="item" data-w="2253" data-h="923">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750011.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750011.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750014.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750014.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="983">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanAndvisitors/t-53750020.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanAndvisitors/st-53750020.jpg"></a></div>
</div>
</div></div></div>
<script>
$('#demo8').flexImages({ rowHeight:600 , truncate: 0});
</script>
