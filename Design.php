<?php
include("DBConnection.php");

function createCountries()
{
	$result = mysql_query("select Nombre from paises order by nombre;");
	while($row = mysql_fetch_array($result)) 
	{
		echo "<option>".$row['Nombre'];
	}	
}

function createFeatures()
{
	$result = mysql_query("select Nombre from CaracteristicasDeDiseño order by nombre;");
	while($row = mysql_fetch_array($result)) 
	{
		echo "<option>".$row['Nombre']."</option>";
	}	
}

function createTypes()
{
	$result = mysql_query("select Nombre from TiposDeDiseño order by nombre;");
	while($row = mysql_fetch_array($result)) 
	{
		echo "<option>".$row['Nombre']."</option>";
	}	
}

function createRates($num)
{
	$cont = 1;
	while($cont <= $num)
	{
		echo "<option>".$cont;
		$cont++;
	}
}

function designImages($Images)
{
	for($i = 0; $i < sizeof($Images); $i++)
	{
		echo
		"<img src=".$Images[$i]."
        height = '300px'
        width = '300px'><br>";
	}
}

function designTypes($Types)
{
	for($i = 0; $i < sizeof($Types); $i++)
	{
		echo "<label>$Types[$i]</label><br>";
	}	
}

function designFeatures($Features)
{
	for($i = 0; $i < sizeof($Features); $i++)
	{
		echo "<label>$Features[$i]</label><br>";
	}
}

function createDesigns()
{
	$result = mysql_query
	("
	SELECT dis.idDiseño, 
		   dis.titulo,
		   dis.descripcion,
		   date(dis.FechaDeCreacion) Fecha,
		   CONCAT(user.Nombre,' ',user.Apellido1,' ',user.Apellido2) Autor,
		   dis.PromedioPuntos,
		   dis.CantidadVisitas,
		   estado.nombre Estado,
		   pais.nombre Pais, 
		   Group_concat(DISTINCT car.nombre ORDER BY car.nombre SEPARATOR ',') Features, 
		   Group_concat(DISTINCT tipo.nombre ORDER BY tipo.nombre SEPARATOR ',') Types,
		   Group_concat(DISTINCT img.url SEPARATOR ',') Images
	FROM diseños dis
	INNER JOIN finalDesignsResults des ON des.idDiseño = dis.idDiseño
	INNER JOIN estadoDeDiseños estado ON dis.IdEstado = estado.IdEstado
	INNER JOIN imagenes img ON img.idDiseño = dis.idDiseño
	INNER JOIN diseñosXcaracteristicas DXC ON dis.idDiseño = DXC.idDiseño
	INNER JOIN caracteristicasDeDiseño car ON DXC.idCaracteristica = car.idCaracteristica
	INNER JOIN tiposDeDiseño tipo ON car.idTipo = tipo.idTipo
	INNER JOIN usuarios user ON dis.idUsuario = user.idUsuario
	INNER JOIN paises pais ON user.idPais = pais.idPais
	GROUP BY dis.idDiseño
	ORDER BY dis.idDiseño;");
	if (!$result) 
	{
    	die('Invalid query: ' . mysql_error());
	}
	while($row = mysql_fetch_array($result)) 
	{
		newDesign($row["idDiseño"],$row["titulo"],$row["descripcion"],$row["Fecha"],$row["PromedioPuntos"],$row["CantidadVisitas"],$row["Estado"],$row["Pais"],explode(",",$row["Features"]),explode(",",$row["Types"]),explode(",",$row["Images"]),$row["Autor"]);
	}
}
function newDesign($idDiseño, $title, $description, $date, $rate, $visits, $state, $country, $Features, $Types, $Images, $Author)
{

	echo "
	    <form action='DesignDB' method='Post' id='design'>
        <h3>Title:</h3>
        <label>$title</label><br>
        <h3>Description:</h3>
        <label>$description</label><br>
        <h3>Author:</h3>
        <label>$Author</label><br>
        <h3>Post date:</h3>
        <label>$date</label><br>
        <h3>Average rate:</h3>
        <label>$rate</label><br>
        <h3>Visits:</h3>
        <label>$visits</label><br>
        <h3>Design state:</h3>
        <label>$state</label><br>
         <h3>Country:</h3>
        <label>$country</label><br>
        <h3>Caracteristics:</h3><br>
        <div id = 'Feacture'>";
            designFeatures($Features);
	echo
        "</div>
        <h3>Types:</h3><br>
        <div id = 'Type'>";
            designTypes($Types);
    echo
	    "</div>
		 <div id='images'>";
			designImages($Images);
	echo
		"
		</div>";
	if($state == "En subasta")
	{
		echo
			"
        	<input type='submit' value='Make an offer'>
        	<input type='hidden' name='idDesign' value=$idDiseño>";
	}
	echo "    
	</form>
	<br><br><br>";
}
?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="Design.css">
</head>
<body>
	<form action="DesignDB.php" method= "Post">
        <datalist id="countries">
            <?php createCountries(); ?>
        </datalist>
        
        <datalist id="rates">
            <?php createRates(5); ?>
        </datalist>
    	<h3>Date Ranges:</h3><br>
        <input id="RangeDate1" name="date1" type="Date">
        <input id="RangeDate2" name="date2" type="Date"><br>
        <h3>Select a country</h3><br>
        <input id="Country" name="country" type="text"  placeholder="Countries" list="countries"><br>
        <h3>Select a rate</h3><br>
        <input id="Rates" name="rate" type="text" placeholder="Rate" list="rates" ><br>
        <h3>Select the designs characteristic</h3><br>
        <select multiple="multiple" placeholder="Characteristics" name="features[]"><br>
            <?php createFeatures() ?>
        </select><br>
        <h3>Select the designs types</h3><br>
        <select multiple="multiple" placeholder="Types" name="types[]"><br>
            <?php createTypes() ?>
        </select><br>
        
        <input type="submit" value="Search"><br>
    </form>
	<center>
    <?php createDesigns(); ?>
    
</body>
</html>