<?php
	header('Content-Type: application/json');
	if(isset($_POST) && !empty($_POST)) {
		
		$mail = $_POST['mail'];
		$object = $_POST['subject'];
		$message = $_POST['message'];
		$to = 'laureboutmy@gmail.com';
		$subject = 'Message from ' . $mail . ' about ' . $object;
		$content= '
		<html>
	    <head>
				<title>' . $subject . '</title>
	    </head>
	    <body>
	     	' . $message . '
	    </body>
	  </html>';
		$mailheader = 'MIME-Version: 1.0' . "\r\n";
	  $mailheader .= 'Content-type: text/html; charset=utf-8' . "\r\n";
	  $mailheader .= 'From:' . $email . "\r\n";

		mail($to, $subject, $content, $mailheader) or die('Error!');
		echo json_encode(true);	
	} else { echo json_encode(false); }
?>