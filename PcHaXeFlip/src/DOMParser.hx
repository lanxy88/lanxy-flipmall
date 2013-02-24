extern class DOMParser 
{
	function new() : Void;
	function parseFromString( t : String, mime : String ) : Dynamic;
	function getElementsByTagName( name : String ) : Dynamic;
}