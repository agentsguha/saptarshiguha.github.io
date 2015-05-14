---
layout: post2
title: The XPan and Pakon Getting Along
excerpt: XPan is 35mm and the Pakon scans 35mm. So can I? Yes, using the TLXCLientDemo  ....
tags: xpan, pakon, 35mm, film, panoramic
---

  

<!-- Main CSS Body goes here -->
<div class="row">
<div class="col-sm-2"></div>
<div class="col-sm-8">


<h1> {{ page.title }} </h1>
<div class="pdate"> {{ page.date | date: "%b %d, %Y" }} </div>

<div class="row">
<div class="col-xs-9">
<p>

Not happy with scanning quality and price combinations that abound in the San
Francisco bay area, I once again fell for the praises of an internet fan
club. This club swears by the Pakon 135+ for it's swiftness and quality in
scanning 35mm film (and it only scans this film). The Pakon 135+ scans at a
3000x2000 resolution but can scan in 12 bit raw mode via a program called
TLXClientDemo. Sellers on Ebay are charging a pretty penny for this, and expect
to pay upwards of 500 dollars  (last year it went for ~250). If you do
get one (or have one), join the Pakon Facebook group. The group members show of
some lovely images scanned with the Pakon and there is a very helpful file
section. My likes include Pakon Polish Lightroom action and
<i>pakon-error149-fix.zip</i> (though I haven't done a before/after comparison
for the latter)

</p>

<p> So the XPan is 35mm and the Pakon scans 35mm. So can I? Yes, using the
TLXCLientDemo program, it is possible to scan the beautiful panoramic images of
the XPan. The default settings create each image as corresponding to a single 35mm
frame. The XPan, as you might be aware, uses two frames per image. Most
fortuitously, the user can adjust the start and end of each image within TLXClientemo. I'll describe
exactly(well roughly) how to do it.  </p>

<p>
Start TLXClientDemo, you should see Figure 1, now press scan. Figure 2 should be
the next screen. Since I'm scanning Tri-X 400, i checked B&W C41 (note the
TLXCLientDemo doesn't scan true black and white), base 16, the number of
frames in the strip. I would turn of the scratch removal option if you're
scanning the B&W film. Great, now hit the scan button. 
</p>

<p>
Take the negative strip (I had 6 frames or equivalently 3 XPan images to a
strip) and place it in the scanner. Emulsion side facing inside, the smallest
number goes in first and will appear back to front (on the top, given that the
emulsion side is facing inside). Wait till the green light (farthest light in
the Figure 5), starts blinking then gently guide the negative in. The Pakon will
complain if you  guide it in before the green light starts blinking. A little
bit of patience is a useful quality to have while scanning.
</p>

<div class="row">
	<div class="col-xs-12">
<figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/DSC00153.JPG"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/DSC00153.JPG" width='220'></a>
    <figcaption>Figure 3: Emulsion side of negative, how to place</figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/DSC00154.JPG"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/DSC00154.JPG" width='220'></a>
    <figcaption>Figure 4: Placed into scanner</figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/DSC00155.JPG"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/DSC00155.JPG" width='220'></a>
    <figcaption>Figure 5: Wait for the farthest green line to blink </figcaption>
    </figure>
</div>
</div>

<p>
Once the scanning is over, a box like Figure 6 will appear. If you film does not
have DX Edge coding (the bar codes on the edge of the film, present in the newer
color films and some B&W like Ilford HP5+), you'll see <i>"DX Read: BAD"</i>. Also, the
button labeled <i>"Move Oldest Roll in Scan Group to Save Group"</i> (left column) will
be clickable. Click it and you'll see your images (see Figure 7)! If you got the "DX Read"
error, just change the names of your files as they wont be saved with the frame
numbers.
</p>

<p>
Now for the most important bit: click on the <i>"Framing"</i> button on the left, and
change the value of "left" (see Figure 7) and click <i>"Apply"</i>. This sets the
beginning of the image and you can see a thin black edge on the left of the
image in Figure 8 which means I need a larger <i>"Left"</i> value. Now, click on 
<i>"Adjust Cropping"</i> and change the value of <i>"Right"</i> to include the right end
of the image. As you can see in my image ( Figure 8), I've chosen too much and
have included the next image. Adjust accordingly and click <i>"Apply"</i>.
</p>
<div class="row">
	<div class="col-lg-12">
    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx7.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx7.png" width='320'></a>
    <figcaption>Figure 8: Scan  Framing  </figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx8.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx8.png" width='320'></a>
    <figcaption>Figure 9: Scan  Saving  </figcaption>
    </figure>

</div>
 </div>

<p>
Click on <i>"Save"</i>. A box like Figure 9 will appear. You can save the color images as
RAW which can then be edited in Photoshop and ColorPerfect. To do that, 
uncheck <i>"Use Color Correction..."</i> (which will uncheck the options below
it). Choose <i>"To Client Memory"</i>, and check <i>"Planar"</i> and <i>"Add File
Header"</i>. Now click OK. The raw image will be saved to C:\Temp by default.
</p>


<p>
To save it as JPG, click on <i>"Use Scratch Removal"</i>, check the <i>"Use Color
Correction..."</i> boxes and <i>"To Disk"</i> . I strongly recommend to save a JPG if
you save a RAW. You'll see why.
</p>

<p>
To open the RAW in Photoshop, enter the width and height of the image( as noted
from the saved JPG), then 3 channels,non-interleaved, IBM PC format, and a 16
byte header. Excellent.
</p>

<p>
You can now click on <i>"Framing"</i> again to frame the next image. Whatever you
do, <i>do not</i> click on <i>"Four"</i> for <i>"Pictures Shown"</i>. For me, the framing button
blanked out and I had to rescan. You can click on <i>"Four"</i> to view the
images, but please do not click on <i>"Framing"</i>! Go to back to one image
view and then frame.
</p>


</div>

	<div class="col-xs-3">
    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx1.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx1.png" width='250'></a>
    <figcaption>Figure 1: TLCClientDemo splash page</figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx2.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx2.png" width='250'></a>
    <figcaption>Figure 2: Scan dialogue </figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx4.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx4.png" width='250'></a>
    <figcaption>Figure 6: Scan Warnings </figcaption>
    </figure>

    <figure>
    <a href="{{ site.url }}/images/photos/xpanpakon/tlx6.png"> <img  style="margin:1em 0px;" src="{{ site.url }}/images/photos/xpanpakon/tlx6.png" width='250'></a>
    <figcaption>Figure 7 Your image appears </figcaption>
    </figure>

	</div>

</div>

</div>
</div>


<div class="row">
<div class="col-sm-2"></div>
<div class="col-sm-8">

<h2> Proof Picture Positive</h2>

At the end of the day, I got some nice scans from expired Kodak 800 film( found
in my wife's box of hoarding, a person who is least interested in photography)
and a roll of Tri-X 400 (taken in Seattle). I saved to JPG and touched them up
in  Lightroom v5.

<br/>
<div id="demo6" class="flex-images" style="padding-top:0.5em;">
<div class="item" data-w="2400" data-h="885">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-1.jog.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-1.jog.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="897">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-11A.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-11A.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="905">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-12A.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-12A.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="903">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-22A.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-22A.jpg"></a></div>
</div>
</div>
</div>
</div>
<script>
$('#demo6').flexImages({ rowHeight:430 , truncate: 0});
</script>

<div class="row" style="margin:0.5em;">
<a href="{{ site.url }}/images/photos/xpanpakon/t-13.jpg" ><img class='bannerimg' src="{{ site.url }}/images/photos/xpanpakon/t-13.jpg"></a>
</div>


<div class="row"><div class="col-sm-2"></div>
<div class="col-sm-8">

<div id="demo8" class="flex-images" style="padding-top:0.5em;">
<div class="item" data-w="2400" data-h="903">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-18A.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-18A.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="895">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-3.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-3.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="891">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-4.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-4.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="891">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-5.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-5.jpg"></a></div>
</div>
</div>

</div>
</div>
<script>
$('#demo8').flexImages({ rowHeight:430 , truncate: 0});
</script>


<div class="row" style="margin:0.5em;">
<a href="{{ site.url }}/images/photos/xpanpakon/t-cross2.jpg" ><img class='bannerimg' src="{{ site.url }}/images/photos/xpanpakon/t-cross2.jpg"></a>
</div>

<div class="row"><div class="col-sm-2"></div>
<div class="col-sm-8">
<div id="demo9" class="flex-images" style="padding-top:0.5em;">
<div class="item" data-w="2400" data-h="880">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-docks.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-docks.jpg"></a></div>
</div>
<div class="item" data-w="695" data-h="1600">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-DX_ERROR.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-DX_ERROR.jpg"></a></div>
</div>
<div class="item" data-w="2400" data-h="885">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-troll.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-troll.jpg"></a></div>
</div>
<div class="item" data-w="1200" data-h="555">
	<div class="img"><a href="{{ site.url }}/images/photos/xpanpakon/t-1.jpg.jpg"><img src="{{ site.url }}/images/blank.gif" data-src="{{ site.url }}/images/photos/xpanpakon/st-1.jpg.jpg"></a></div>
</div>
</div>
</div>
</div>

<script>
$('#demo9').flexImages({ rowHeight:430 , truncate: 0});
</script>



  