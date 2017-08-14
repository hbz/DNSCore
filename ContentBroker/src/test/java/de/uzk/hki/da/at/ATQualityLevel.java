package de.uzk.hki.da.at;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.util.TreeMap;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import de.uzk.hki.da.model.Object;
import de.uzk.hki.da.utils.C;

public class ATQualityLevel extends AcceptanceTest {

	private static final String SOURCE_NAME_2 = "ATQualityLevel_2";
	private static final String SOURCE_NAME_3 = "ATQualityLevel_3";
	private static final String SOURCE_NAME_4_WithNonSupportedF = "ATQualityLevel_4_WithNonSupportedF";
	private static final String SOURCE_NAME_4_OnlyNonSupported = "ATQualityLevel_4_OnlyNonSupported";

	private static final String SOURCE_NAME_5 = "ATQualityLevel_5";
	private static final String ORIG_NAME_DELTA = "ATQualityDeltaTest";

	private static final String ORIG_NAME = "ATQualityTest";

	//private static final String ALIEN_NAME = "ATKeepModDates";

	private String idiName;

	@Before
	public void setUp() throws IOException {
	}

	/*@Test
	public void testNonSupported() throws IOException {
		ath.putSIPtoIngestArea(SOURCE_NAME_4_OnlyNonSupported, C.FILE_EXTENSION_TGZ, ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.InWorkflow);
 		ath.waitForObjectPublishedState(ORIG_NAME,0);
 		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
 		
 		Object obbi = ath.getObject(ORIG_NAME);

		idiName = obbi.getIdentifier();
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),4);
 		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),1);
	}
	*/
	@Test
	public void deltaTest() throws IOException {
		ath.putSIPtoIngestArea(SOURCE_NAME_2, C.FILE_EXTENSION_TGZ, ORIG_NAME_DELTA);
		ath.awaitObjectState(ORIG_NAME_DELTA, Object.ObjectStatus.InWorkflow);
 		ath.waitForObjectPublishedState(ORIG_NAME_DELTA,0);
 		ath.awaitObjectState(ORIG_NAME_DELTA, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
 		
 		Object obbi = ath.getObject(ORIG_NAME_DELTA);
		idiName = obbi.getIdentifier();
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),2);
 		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),1);

		ath.putSIPtoIngestArea(SOURCE_NAME_3, C.FILE_EXTENSION_TGZ, ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.InWorkflow);
		ath.waitForDefinedPublishedState(ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
		
		obbi = ath.getObject(ORIG_NAME);
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),3);
		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),2);
		
		ath.putSIPtoIngestArea(SOURCE_NAME_4_WithNonSupportedF, C.FILE_EXTENSION_TGZ, ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.InWorkflow);
		ath.waitForDefinedPublishedState(ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
		
		obbi = ath.getObject(ORIG_NAME);
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),4);
		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),3);
		
 		
 		/////////////////////////////////
		
		ath.putSIPtoIngestArea(SOURCE_NAME_3, C.FILE_EXTENSION_TGZ, ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.InWorkflow);
		ath.waitForDefinedPublishedState(ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
		
		obbi = ath.getObject(ORIG_NAME);
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),3);
		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),4);
		
		
		ath.putSIPtoIngestArea(SOURCE_NAME_2, C.FILE_EXTENSION_TGZ, ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.InWorkflow);
		ath.waitForDefinedPublishedState(ORIG_NAME);
		ath.awaitObjectState(ORIG_NAME, Object.ObjectStatus.ArchivedAndValidAndNotInWorkflow);
		
		obbi = ath.getObject(ORIG_NAME);
 		assertEquals("Object Level: "+obbi.getQuality_flag(),obbi.getQuality_flag(),2);
		assertEquals("Package count: "+obbi.getPackages().size(),obbi.getPackages().size(),5);
		
		idiName = obbi.getIdentifier();
 		
	}

	@After
	public void tearDown() {
		distributedConversionAdapter.remove("aip/"+testContractor.getUsername()+"/" + idiName);
	}

}
