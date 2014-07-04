/*
  DA-NRW Software Suite | ContentBroker
  Copyright (C) 2014 LVRInfoKom
  Landschaftsverband Rheinland

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package de.uzk.hki.da.repository;

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.apache.tika.io.IOUtils;
import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Daniel M. de Oliveira
 */
public class CTElasticSearchMetadataIndexTests {

	private static final String LOCALHOST = "localhost";
	private static final String CLUSTER_CI = "cluster_ci";
	private static final String TEST_OBJECT_1 = "test_object_1";
	private static final String TEST_COLLECTION = "test_collection";
	private static final String PORTAL_CI = "portal_ci";
	private static final String _1972 = "1972";
	private static final String YEAR = "@year";
	private static final String DIRECTOR = "@director";
	private static final String TITLE = "@title";
	private static final String FRANCIS_FORD_COPPOLA = "Francis Ford Coppola";
	private static final String THE_GODFATHER = "The Godfather";

	private static final String url = "http://localhost:9200/portal_ci/test_collection/test_object_1";

	private ElasticsearchMetadataIndex index;
	private Map<String,Object> data;

	// TODO get properties from config.properties.ci
	
	@Before
	public void setUp() throws MalformedURLException, ProtocolException, IOException{
		index = new ElasticsearchMetadataIndex();
		index.setCluster(CLUSTER_CI);
		index.setHosts(new String[]{LOCALHOST});
		data = new HashMap<String,Object>();
		data.put(TITLE,THE_GODFATHER);
		data.put(DIRECTOR,FRANCIS_FORD_COPPOLA);
		data.put(YEAR,_1972);
		deleteIfExists();
		assertTrue(getBody()==null);
	}
		
	
	@Test
	public void test() throws MalformedURLException, IOException{
		
		try {
			index.indexMetadata(PORTAL_CI, TEST_COLLECTION, TEST_OBJECT_1, data);
		} catch (MetadataIndexException e) {
			fail();
		}

		JSONObject jsonObj = new JSONObject(getBody());
		JSONObject source  = (JSONObject) jsonObj.get("_source");
		assertEquals(THE_GODFATHER,source.get(TITLE));
		assertEquals(FRANCIS_FORD_COPPOLA,source.get(DIRECTOR));
		assertEquals(_1972,source.get(YEAR));
		
	}

	private String getBody() throws IOException{
		HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
		con.setRequestMethod("GET");
		if (con.getResponseCode()!=200) {
			con.disconnect();
			return null;
		}
		if (con.getInputStream()==null) {
			con.disconnect();
			return null;
		}
		BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream()));
		String result = IOUtils.toString(in);
		con.disconnect();
		
		return result;
	}
	
	private void deleteIfExists() throws MalformedURLException, ProtocolException, IOException{
		if (getBody()!=null){
			System.out.println("delete");
			HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
			con.setRequestMethod("DELETE");
			con.getInputStream();
			con.disconnect();
		}
	}
}
