import Formula;

class TestIntegrate extends haxe.unit.TestCase
{
	public function testValue() {
		var f:Formula;
		var result:Float;
		f = "x";
		result=Integrate.trapz(f, "x", 0, 10, 10);	
		assertEquals(result, 50.5);
	}
}
