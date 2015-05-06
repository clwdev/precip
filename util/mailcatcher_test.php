<?php
$to      = 'fake@fake.fake';
$subject = 'mailcatcher test';
$message = 'hello world!';
$headers = 'From: webmaster@example.com' . "\r\n" .
    'Reply-To: webmaster@example.com' . "\r\n" .
    'X-Mailer: PHP/' . phpversion();

mail($to, $subject, $message, $headers);
?>

Mail sent! Go check <a href="http://<?php echo $_SERVER['HTTP_HOST']; ?>:1080">MailCatcher</a>!