<?php

require_once(dirname(__FILE__) . '/Base.php');

class Unit_EmailIntegration_EmailMarketer_Field_Dropdown extends Unit_EmailIntegration_EmailMarketer_Field_Base
{
	public $providerFieldClassName = 'Interspire_EmailIntegration_EmailMarketer_Field_Dropdown';

	/**
	* @return array
	*/
	public function dataProviderFromSubscriptionToProvider ()
	{
		$data = array(
			array(new Interspire_EmailIntegration_Field_Address, 'Test.', 'Test.'),
			array(new Interspire_EmailIntegration_Field_Address, array('Test', 'test'), 'Test test'),
			array(new Interspire_EmailIntegration_Field_Bool, true, 'true'),
			array(new Interspire_EmailIntegration_Field_Bool, false, 'false'),
			array(new Interspire_EmailIntegration_Field_Currency, 'Test.', ''),
			array(new Interspire_EmailIntegration_Field_Currency, array('numeric' => 1, 'formatted' => '$1.00'), '$1.00'),
			array(new Interspire_EmailIntegration_Field_Date, 1273025038, '5th May 2010'), // if default export date format is ever changed this will break
			array(new Interspire_EmailIntegration_Field_Date, '2010-12-31', '31st Dec 2010'),
			array(new Interspire_EmailIntegration_Field_Email, 'test@example.com', 'test@example.com'),
			array(new Interspire_EmailIntegration_Field_Float, 1.2, 1.2),
			array(new Interspire_EmailIntegration_Field_Int, 2, 2),
			array(new Interspire_EmailIntegration_Field_Ip, '127.0.0.1', '127.0.0.1'),
			array(new Interspire_EmailIntegration_Field_String, 'Test', 'Test'),
			array(new Interspire_EmailIntegration_Field_Array, array('Foo', 'Bar'), 'Foo, Bar'),
		);

		return $data;
	}
}
