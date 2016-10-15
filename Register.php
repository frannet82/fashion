<?php
$host = "localhost";
$user = "root";
$pw = "z2n4p9d0e8";
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
function createRoles()
{
	$result = mysql_query("select Nombre from roles order by nombre;");
	while($row = mysql_fetch_array($result)) 
	{
		if($row['Nombre'] != "Admin")
		{
			echo "<option>".$row['Nombre'];
		}
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
							<li><a href="Main.php">Home</a></li>
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
					    <form class="form-horizontal" action='RegisterDB.php' method="Post">
						  <font color="White" size="20"> Register </font>
						  <p></p>
						  <p></p>
						  <p></p>
							<div class="control-group info">
							<div class="controls">
							<input type="text" id="inputInfo" name="Name" placeholder="Name" required>
							</div>
							</div>
							<div class="control-group info">
							<div class="controls">
							<p></p>
							<input type="text" id="inputInfo" name="FirstName" placeholder="First Last Name" required>
							</div>
							</div>
							<div class="control-group info">
							<div class="controls">
							<p></p>
							<input type="text" id="inputInfo" name="LastName" placeholder="Second Last Name" required>
							</div>
							</div>
							
							<div class="control-group">
							<p></p>
							<div class="controls">
							<input type="email" id="inputEmail" name="Email" placeholder="Email" required>
							</div>
							</div>

							<div class="control-group">
							<p></p>
							<div class="controls">
							<input type="password" id="inputPassword" name="Password" placeholder="Password" required>
							</div>
							</div>
							
							<div class="control-group">
							<div class="controls">
						    <p></p>
							<font color="white" size="5">Select roles</font>
							<center>
                            <div id="mainselection">
							<select multiple="multiple" name="Roles[]" required>
                            	<?php createRoles(); ?>
                            </select>
                            </div>
                            <br>
                            <font color="white" size="5">Select your country</font>

							<div id="mainselection">
							<select name="Country" required>
                            	<?php createCountries(); ?>
                            </select>
							</div>
							<p></p>
						    <p></p>
						    <p></p>
							<p></p>
						    <p></p>
						    <p></p>
							</center>
							<font color="white" size="5">Birthday</font >		
                            <p></p>			
							<input type="Date" name="Birth" required>                     
							<br>
                            <br>                   
                            <p>
						        <input type="submit" name="submit" value="Register">
						    </p>
							</div>
							</div>
					</form>
					
					</div>
				</div>
			</section>
	</body>
</html>