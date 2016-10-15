<?php
include("DBConnection.php");
	
if($_SESSION['actualUser'] != NULL)
{
	$_SESSION['Login'] = NULL;
	$_SESSION['Logout'] = "Logout";
}
else
{
	$_SESSION['Login'] = "Login";
	$_SESSION['Logout'] = NULL;
}
function getUserName()
{
	if($_SESSION['actualUser'] != NULL)
	{
		$idActualUser = $_SESSION['actualUser'];
		$result = mysql_query("select * from usuarios where idUsuario = '$idActualUser';");
		$row = mysql_fetch_array($result);
		return $row["Nombre"]." ".$row["Apellido1"]." ".$row["Apellido2"];
	}
	else
	{
		return NULL;
	}
}
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>Fashion</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		<!--[if lte IE 8]><script src="css/ie/html5shiv.js"></script><![endif]-->
		<script src="js/jquery.min.js"></script>
		<script src="js/jquery.poptrox.min.js"></script>
		<script src="js/jquery.scrolly.min.js"></script>
		<script src="js/jquery.scrollgress.min.js"></script>
		<script src="js/skel.min.js"></script>
		<script src="js/init.js"></script>
		<noscript>
			<link rel="stylesheet" href="css/skel.css" />
			<link rel="stylesheet" href="css/style.css" />
			<link rel="stylesheet" href="css/style-wide.css" />
			<link rel="stylesheet" href="css/style-normal.css" />
		</noscript>
		<!--[if lte IE 8]><link rel="stylesheet" href="css/ie/v8.css" /><![endif]-->
	</head>
	<body>
		<!-- Header -->
			<header id="header" >
				
				<!-- Ventana de navegacion -->
					<nav id="nav" >
						<ul>
							<li><a><?php echo getUserName(); ?></a></li>
							<li><a href="LoginDB.php"><?php echo($_SESSION['Logout']); ?></a></li>
							<li><a href="Login.php"><?php echo($_SESSION['Login']); ?></a></li>
                            <li><a href="#contact">Notifications</a></li>
							<li><a href="UserDesigns.php">Make an auction</a></li>
                            <li><a href="#Principal">Home</a></li>
						</ul>
					</nav>

			</header>
			
		<!-- Principal -->
			<section id="Principal" class="main style1 dark fullscreen">
				<div class="content container small">
					<header>
					<h2>
					<a href="#">Fashion</a>
					<a href="#">Design</a>
				    </h2>
					</header>
					<footer>
						<a href="#PaginaPrincipal2" class="button style2 down">More</a>
					</footer>
				</div>
			</section>
		
		<!-- PaginaPrincipal2 -->
			<section id="PaginaPrincipal2" class="main style2 right dark fullscreen">
				<div class="content box style2">
					<header>
						<h1>What I Do</h1>
					</header>
					<p>Lorem ipsum dolor sit amet et sapien sed elementum egestas dolore condimentum. 
					Fusce blandit ultrices sapien, in accumsan orci rhoncus eu. Sed sodales venenatis arcu, 
					id varius justo euismod in. Curabitur egestas consectetur magna.</p>
				</div>
				<a href="#PaginaPrincipal3" class="button style2 down anchored">Next</a>
			</section>
		
		<!-- Two -->
			<section id="PaginaPrincipal3" class="main style2 left dark fullscreen">
				<div class="content box style2">
					<header>
						<h1>Who I Am</h1>
					</header>
					<p>Lorem ipsum dolor sit amet et sapien sed elementum egestas dolore condimentum. 
					Fusce blandit ultrices sapien, in accumsan orci rhoncus eu. Sed sodales venenatis arcu, 
					id varius justo euismod in. Curabitur egestas consectetur magna.</p>
				</div>
				<a href="#work" class="button style2 down anchored">Next</a>
			</section>
			
		<!-- Work -->
			<section id="work" class="main style3 primary">
				<div class="content container">
					<header>
						<h2>Top Fashion</h2>
						<p></p>
					</header>
					
					<!-- Lightbox Gallery  -->
						<div class="container small">
							<div class="row flush images">
								<div class="6u"><a href="Login.php" class="image fit from-left"><img src="images/thumbs/01.jpg"  /></a></div>
								<div class="6u"><a href="images/fulls/02.jpg" class="image fit from-right"><img src="images/thumbs/02.jpg"  /></a></div>
							</div>
							<div class="row flush images">
								<a href="images/fulls/03.jpg" class="image fit from-left"><img src="images/thumbs/03.jpg"  /></a>
							</div>
						</div>
						

				</div>
			</section>
			<p></p>
			<p></p>
			
		<!-- Footer -->
			<footer id="footer">

				<!-- Icons -->
					<ul class="actions">
						<li><a href="#" class="icon fa-twitter"><span class="label">Twitter</span></a></li>
						<li><a href="#" class="icon fa-facebook"><span class="label">Facebook</span></a></li>
						<li><a href="#" class="icon fa-google-plus"><span class="label">Google+</span></a></li>
						<li><a href="#" class="icon fa-dribbble"><span class="label">Dribbble</span></a></li>
						<li><a href="#" class="icon fa-pinterest"><span class="label">Pinterest</span></a></li>
						<li><a href="#" class="icon fa-instagram"><span class="label">Instagram</span></a></li>
					</ul>

				<!-- Menu -->
					<ul class="menu">
						<li>&copy; Untitled</li><li>Design: <a href="http://html5up.net">HTML5 UP</a></li>
					</ul>
			
			</footer>

	</body>
</html>