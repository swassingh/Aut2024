<html>
<head>
	<title>My Search</title>
	<style>
		body {
			font-family: Arial, sans-serif;
			background-color: #f4f4f4;
			margin: 0;
			padding: 0;
		}

		h1 {
			color: #333;
			text-align: center;
			margin-top: 50px;
		}

		p {
			color: #666;
			text-align: center;
		}

		form {
			display: flex;
			justify-content: center;
			margin-top: 20px;
		}

		input[type="text"] {
			padding: 10px;
			font-size: 16px;
			border: 1px solid #ccc;
			border-radius: 4px;
			width: 300px;
		}

		input[type="submit"] {
			padding: 10px 20px;
			font-size: 16px;
			border: none;
			border-radius: 4px;
			background-color: #5cb85c;
			color: white;
			cursor: pointer;
			margin-left: 10px;
		}

		input[type="submit"]:hover {
			background-color: #4cae4c;
		}

		ol {
			text-align: center;
			padding-left: 0;
			list-style-position: inside;
		}

		ol li {
			display: inline;
			margin: 0 10px;
			color: #333;
		}

		a {
			color: #337ab7;
			text-decoration: none;
		}

		a:hover {
			text-decoration: underline;
		}
	</style>
</head>

<body>

<h1>My Search</h1>

<p>Paul Graham is a programmer, writer, and venture capitalist. He is known for his work on Lisp, his essays on startups and programming, and for co-founding the startup accelerator Y Combinator. His website, paulgraham.com, hosts a collection of his essays on various topics including technology, startups, and life.</p>

<p>I would try searching with the queries mentioned above in this document. I have uploaded the same index. You should get the same results as the BM25.</p>

<p>
Queries I recommend:
<ol>
<li>addiction</li>
<li>life</li>
<li>age</li>
<li>USA</li>
</ol>
</p>

<form action="search.php" method="post">
	<input type="text" size=40 name="search_string" value="<?php echo $_POST["search_string"];?>"/>
	<input type="submit" value="Search"/>
</form>

<?php
	if (isset($_POST["search_string"])) {
		$search_string = $_POST["search_string"];
		
		file_put_contents("logs.txt", $search_string.PHP_EOL, FILE_APPEND | LOCK_EX);

		$qfile = fopen("query.py", "w");

		fwrite($qfile, "import pyterrier as pt\nif not pt.started():\n\tpt.init()\n\n");
		fwrite($qfile, "import pandas as pd\nqueries = pd.DataFrame([[\"q1\", \"$search_string\"]], columns=[\"qid\",\"query\"])\n");
		fwrite($qfile, "index = pt.IndexFactory.of(\"./webcrawl_index/data.properties\")\n");
		fwrite($qfile, "bm25 = pt.BatchRetrieve(index, wmodel=\"BM25\")\n");
		fwrite($qfile, "results = bm25.transform(queries)\n");

		for ($i=0; $i<5; $i++) {
			fwrite($qfile, "print(index.getMetaIndex().getItem(\"filename\",results.docid[$i]))\n");
			fwrite($qfile, "if index.getMetaIndex().getItem(\"title\", results.docid[$i]).strip() != \"\":\n");
			fwrite($qfile, "\tprint(index.getMetaIndex().getItem(\"title\",results.docid[$i]))\n");
			fwrite($qfile, "else:\n\tprint(index.getMetaIndex().getItem(\"filename\",results.docid[$i]))\n");
   		}
   
   		fclose($qfile);

   		exec("ls | nc -u 127.0.0.1 10001");
   		sleep(3);

   		$stream = fopen("output", "r");

   		$line=fgets($stream);

   		while(($line=fgets($stream))!=false) {
   			$clean_line = preg_replace('/\s+/',',',$line);
   			$record = explode("./", $clean_line);
   			$line = fgets($stream);
   			echo "<a href=\"http://$record[1]\">".$line."</a><br/>\n";
   		}

   		fclose($stream);
   
  		exec("rm query.py");
  		exec("rm output");
   		}
?>

</body>
</html>

