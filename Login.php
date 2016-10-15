<!DOCTYPE html>
<html lang="en">
    <head>
		<meta charset="UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"> 
		<meta name="viewport" content="width=device-width, initial-scale=1.0"> 
        <title></title>
        <meta name="description" content="Custom Login Form Styling with CSS3" />
        <meta name="keywords" content="css3, login, form, custom, input, submit, button, html5, placeholder" />
        <meta name="author" content="Codrops" />
        <link rel="shortcut icon" href="../favicon.ico"> 
        <link rel="stylesheet" type="text/css" href="css/style2.css" />
	

		<script src="js/modernizr.custom.63321.js"></script>
		<!--[if lte IE 7]><style>.main{display:none;} .support-note .note-ie{display:block;}</style><![endif]-->
		<style>	
			@import url(http://fonts.googleapis.com/css?family=Raleway:400,700);
			body {
				background: #000000 url(images/bg2.jpg) no-repeat center top;
				-webkit-background-size: cover;
				-moz-background-size: cover;
				background-size: cover;
			}
			.container > header h1,
			.container > header h2 {
				color: #000;
				text-shadow: 0 1px 1px rgba(0,0,0,0.7);
			}
		</style>
    </head>
    <body>
        <div class="container">
			
			<section class="main" style="text-align:right">
				<form class="form-4" action='LoginDB.php' method='Post'>
				   <center> <h1>Sign up</h1></center>
				    <p>
				        <label for="login">Email</label>
				        <input type="text" name="login" placeholder="Email" required>
				    </p>
				    <p>
				        <label for="password">Password</label>
				        <input type="password"  name='password' placeholder="Password" required> 
				    </p>

				    <p>
				        <input type="submit" name="submit" value="Continue">
				    </p>
					<p>
					<center>
					<h1></h1>

					<a href="Main.php" type="Button" color="white" >
					Forgot your password
					</p></a>
				   <a href="Register.php">
				   Create an account now
				   </a>
				    </p>
                   </center>				   
				</form>​
			</section>
        </div>
    </body>
</html>