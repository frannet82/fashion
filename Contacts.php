<?php
$host = "localhost";
$user = "root";
$pw = "qwerty123";
$db = "fashion";

$con = mysql_connect($host,$user,$pw) or die("Problemas al conectar");
mysql_select_db($db, $con) or die("Problemas al conectar la bd");
mysql_set_charset('utf8');

function createCountries()
{
	$result = mysql_query("select Nombre from paises order by nombre;");
	while($row = mysql_fetch_array($result)) 
	{
		echo "<option>".$row['Nombre'];
	}	
}
function createContacts()
{
	$result = mysql_query("select Tipo from mediosDeContacto order by Tipo;");
	while($row = mysql_fetch_array($result)) 
	{
		echo "<option>".$row['Tipo'];
	}	
}
?>
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
			   <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
			  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
			  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
			  
			  <script>
			  $(document).ready(function() {
				$("#datepicker").datepicker();
			  });
			  </script>
		<!--[if lte IE 8]><link rel="stylesheet" href="css/ie/v8.css" /><![endif]-->
	</head>
	<body >

		<!-- Header -->
			<header id="header" >
				
				<!-- Ventana de navegacion -->
					<nav id="nav" >
						<ul>
							<li><a href="index2.php">Home</a></li>
						</ul>
					</nav>

			</header>
		
<!-- Login -->
			<section  class="main style3 secondary" >
				<div class="content container" >
					<header>
						<h2></h2>
					</header>
					<div class="box container small" width="-60">
					    <form class="form-horizontal" action='ContactsDB.php' method="Post">
							<font color="white" size="5">Contact Option</font>
                            <center>
                            <br>
							<div id="mainselection">
                                <select name="concactType">
                                    <?php createContacts(); ?>
                                </select>
							</div>
							<div id="mainselection2">
								<input type="text" name="concactValue" size="2" ><font color="white"></font>
							</div>
							<br>
                            <br>
							<p>
						        <input type="submit" name="submit" value="Add contact">
						    </p>
						</form>				
					</div>
				</div>
			</section>
	</body>
</html>