#!/bin/sh 
read -p "Type the image directory path 'src' by default, followed by [ENTER]:" src
src=${src:-src}

mkdir thumbs pics originals

for i in $src/*; 
do 
    echo "Copy and rename image : $i" 
    datetime=`identify -verbose "$i" | grep "exif:DateTime:" | awk -F\\  '{print $2"_"$3}' | sed s/:/_/g`
    cp $i originals/$datetime-`basename $i`
    chmod a+r originals/$datetime-`basename $i`
done ; 

echo "Generating thumbnail, please wait"
mogrify  -format gif -path thumbs/  -thumbnail 75x75^ -gravity center -extent 75x75 -auto-orient  originals/* 
echo "Generating pics, please wait"
mogrify  -strip -resize 500x500 -auto-orient -path pics originals/*

cat > index.html <<'EOF'
<html>
	<head>
		<meta http-equiv="Content-type" content="text/html; charset=utf-8">
		<title>GallerifficTitle</title>
		<link rel="stylesheet" href="css/basic.css" type="text/css" />
		<link rel="stylesheet" href="css/galleriffic-2.css" type="text/css" />
		<script type="text/javascript" src="js/jquery-1.3.2.min.js"></script>
		<script type="text/javascript" src="js/jquery.galleriffic.js"></script>
		<script type="text/javascript" src="js/jquery.opacityrollover.js"></script>
		<!-- We only want the thunbnails to display when javascript is disabled -->
		<script type="text/javascript">
			document.write('<style>.noscript { display: none; }</style>');
		</script>
	</head>
	<body>
		<div id="page">
			<div id="container">
				<h1><a href="index.html">GallerifficTitle</a></h1>
				<h2>GallerifficSubTitle</h2>

				<!-- Start Advanced Gallery Html Containers -->
				<div id="gallery" class="content">
					<div id="controls" class="controls"></div>
					<div class="slideshow-container">
						<div id="loading" class="loader"></div>
						<div id="slideshow" class="slideshow"></div>
					</div>
					<div id="caption" class="caption-container"></div>
				</div>
				<div id="thumbs" class="navigation">
					<ul class="thumbs noscript">
EOF

for i in `ls -1 originals/* | sort` ;
do  
    file=`basename $i`
    thumb=${file%\.*}.gif
    echo $thumb 
    echo "<li><a class=\"thumb\" name=\"leaf\" href=\"pics/$file\" title=\"\">" >> index.html
    echo "<img src=\"thumbs/$thumb\" alt=\"\" /></a>" >> index.html
    echo "<div class=\"caption\"><div class=\"download\"><a href=\"$i\">Download Original</a></div>" >> index.html
    echo "<div class=\"image-title\">$file</div><div class=\"image-desc\"></div></div></li>" >> index.html 
done ; 

cat >> index.html <<'EOF'
					</ul>
				</div>
				<div style="clear: both;"></div>
			</div>
		</div>
		<div id="footer">&copy; copyright</div>
		<script type="text/javascript">
			jQuery(document).ready(function($) {
				// We only want these styles applied when javascript is enabled
				$('div.navigation').css({'width' : '300px', 'float' : 'left'});
				$('div.content').css('display', 'block');

				// Initially set opacity on thumbs and add
				// additional styling for hover effect on thumbs
				var onMouseOutOpacity = 0.67;
				$('#thumbs ul.thumbs li').opacityrollover({
					mouseOutOpacity:   onMouseOutOpacity,
					mouseOverOpacity:  1.0,
					fadeSpeed:         'fast',
					exemptionSelector: '.selected'
				});
				
				// Initialize Advanced Galleriffic Gallery
				var gallery = $('#thumbs').galleriffic({
					delay:                     2500,
					numThumbs:                 15,
					preloadAhead:              10,
					enableTopPager:            true,
					enableBottomPager:         true,
					maxPagesToShow:            7,
					imageContainerSel:         '#slideshow',
					controlsContainerSel:      '#controls',
					captionContainerSel:       '#caption',
					loadingContainerSel:       '#loading',
					renderSSControls:          true,
					renderNavControls:         true,
					playLinkText:              'Play Slideshow',
					pauseLinkText:             'Pause Slideshow',
					prevLinkText:              '&lsaquo; Previous Photo',
					nextLinkText:              'Next Photo &rsaquo;',
					nextPageLinkText:          'Next &rsaquo;',
					prevPageLinkText:          '&lsaquo; Prev',
					enableHistory:             false,
					autoStart:                 false,
					syncTransitions:           true,
					defaultTransitionDuration: 900,
					onSlideChange:             function(prevIndex, nextIndex) {
						// 'this' refers to the gallery, which is an extension of $('#thumbs')
						this.find('ul.thumbs').children()
							.eq(prevIndex).fadeTo('fast', onMouseOutOpacity).end()
							.eq(nextIndex).fadeTo('fast', 1.0);
					},
					onPageTransitionOut:       function(callback) {
						this.fadeTo('fast', 0.0, callback);
					},
					onPageTransitionIn:        function() {
						this.fadeTo('fast', 1.0);
					}
				});
			});
		</script>
	</body>
</html>
EOF

read -p "Type the title of your gallery, followed by [ENTER]:" title
title=${title:-Gallery}
sed -i -e "s/GallerifficTitle/$title/g" index.html

read -p "Type the subtitle of your gallery, followed by [ENTER]:" subtitle
subtitle=${subtitle:-Photos}
sed -i -e "s/GallerifficSubTitle/$subtitle/g" index.html

read -p "Type the copyright, followed by [ENTER]:" copyright
copyright=${copyright:-me}
sed -i -e "s/copyright/$copyright/g" index.html
