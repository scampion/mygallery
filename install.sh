#!/bin/sh 
git clone https://github.com/scampion/mygallery.git .

read -p "Type the image directory path 'src' by default, followed by [ENTER]:" src
src=${src:-src}

read -p "Type the title of your gallery, followed by [ENTER]:" title
title=${title:-Gallery}

#read -p "Type the subtitle of your gallery, followed by [ENTER]:" subtitle
#subtitle=${subtitle:-Photos}

read -p "Type the copyright, followed by [ENTER]:" copyright
copyright=${copyright:-me}

mkdir thumbs pics originals

for i in $src/*; 
do 
    echo "Copy and rename image : $i" 
    datetime=`identify -verbose "$i" | grep "exif:DateTime:" | awk -F\\  '{print $2"_"$3}' | sed s/:/_/g`
    cp $i originals/$datetime-`basename $i`
done ; 

echo "Generating thumbnail, please wait"
mogrify  -format gif -path thumbs/  -thumbnail 75x75^ -gravity center -extent 75x75 -auto-orient  originals/* 
echo "Generating pics, please wait"
mogrify  -strip -resize 500x500 -auto-orient -path pics originals/*

cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>GalleryTitle</title>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"> 
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"> 
    <meta name="description" content="Responsive Image Gallery with jQuery" />
    <meta name="keywords" content="jquery, carousel, image gallery, slider, responsive, flexible, fluid, resize, css3" />
    <meta name="author" content="Codrops" />
    <link rel="shortcut icon" href="../favicon.ico"> 
    <link rel="stylesheet" type="text/css" href="css/demo.css" />
    <link rel="stylesheet" type="text/css" href="css/style.css" />
    <link rel="stylesheet" type="text/css" href="css/elastislide.css" />
    <link href='http://fonts.googleapis.com/css?family=PT+Sans+Narrow&v1' rel='stylesheet' type='text/css' />
    <link href='http://fonts.googleapis.com/css?family=Pacifico' rel='stylesheet' type='text/css' />
    <noscript>
      <style>
	.es-carousel ul{
	display:block;
	}
      </style>
    </noscript>
    <script id="img-wrapper-tmpl" type="text/x-jquery-tmpl">	
      <div class="rg-image-wrapper">
	{{if itemsCount > 1}}
	<div class="rg-image-nav">
	  <a href="#" class="rg-image-nav-prev">Previous Image</a>
	  <a href="#" class="rg-image-nav-next">Next Image</a>
	</div>
	{{/if}}
	<div class="rg-image"></div>
	<div class="rg-loading"></div>
	<div class="rg-caption-wrapper">
	  <div class="rg-caption" style="display:none;">
	    <p></p>
	  </div>
	  <div class="rg-download"></div>
	</div>
      </div>
    </script>
  </head>


  <body>
    <div class="container">
      <div class="header">
      </div><!-- header -->
      
      <div class="content">
	<h1>GalleryTitle</h1>
	<div id="rg-gallery" class="rg-gallery">
	  <div class="rg-thumbs">
	    <!-- Elastislide Carousel Thumbnail Viewer -->
	    <div class="es-carousel-wrapper">
	      <div class="es-nav">
		<span class="es-nav-prev">Previous</span>
		<span class="es-nav-next">Next</span>
	      </div>
	      <div class="es-carousel">
		<ul>
EOF

for i in `ls -1 originals/* | sort` ;
do  
    file=`basename $i`
    thumb=${file%\.*}.gif
    echo "<li><a href=\"#\"><img src=\"thumbs/$thumb\" data-large=\"pics/$file\" data-original=\"$i\" alt=\"$file\" data-description=\"$file\"/></a></li>" >> index.html
done ; 

cat >> index.html <<'EOF'
		</ul>
	      </div>
	    </div>
	    <!-- End Elastislide Carousel Thumbnail Viewer -->
	  </div><!-- rg-thumbs -->
	</div><!-- rg-gallery -->
	<p class="sub">&copy; copyright </p>
      </div><!-- content -->
    </div><!-- container -->
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="js/jquery.tmpl.min.js"></script>
    <script type="text/javascript" src="js/jquery.easing.1.3.js"></script>
    <script type="text/javascript" src="js/jquery.elastislide.js"></script>
    <script type="text/javascript" src="js/gallery.js"></script>
  </body>
</html>
EOF

sed -i -e "s/GalleryTitle/$title/g" index.html
sed -i -e "s/copyright/$copyright/g" index.html


