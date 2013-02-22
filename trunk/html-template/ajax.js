Ajax = function(handler){
	var ajax = {};
	
	ajax.xmlhttp = null;
	ajax.handler = handler;
	
	
	var creatXMLHttpRequest = function(){
		var xmlhttp;
		
		if (window.ActiveXObject) {
			var ieArr = ["Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0", "Msxml2.XMLHTTP", "Microsoft.XMLHTTP"];
			for (var i = 0; i < ieArr.length; i++) {
				var xmlhttp = new ActiveXObject(ieArr[i]);
			}
			return xmlhttp;
		}
		else {
			if (window.XMLHttpRequest) {
				return new XMLHttpRequest();
			}
		}	
					
		return xmlhttp;
		
		
	};
	
	ajax.xmlhttp = creatXMLHttpRequest();
	
	
	
	
	ajax.get = function(url,szquery){
		
		var query = "";
		if(szquery != "" && szquery != undefined){
			query = "?" + szquery;
		}
		
		ajax.xmlhttp.open("GET",url+query,true);
		ajax.xmlhttp.send();
	};

	ajax.post = function(url,szquery){
		//alert("url:" + url + "  , querystring : " + szquery);
		ajax.xmlhttp.open("POST",url,true);
		ajax.xmlhttp.onreadystatechange = function(){
			//alert("ajax.xmlhttp.status=" + ajax.xmlhttp.status + ",ajax.xmlhttp.readyState=" +ajax.xmlhttp.readyState);
			if (ajax.xmlhttp.readyState==4 && ajax.xmlhttp.status==200)
			{
				
				//document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
				if(ajax.handler != null){
					ajax.handler(ajax.xmlhttp.responseText);
					
				}
					
			}
		}
		ajax.xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		ajax.xmlhttp.setRequestHeader('If-Modified-Since', '0'); 
		ajax.xmlhttp.send(szquery);
	};
	
	
	return ajax;
}
