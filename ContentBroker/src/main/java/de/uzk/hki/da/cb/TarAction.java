/*
  DA-NRW Software Suite | ContentBroker
  Copyright (C) 2013 Historisch-Kulturwissenschaftliche Informationsverarbeitung
  Universität zu Köln

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

package de.uzk.hki.da.cb;

import java.io.File;
import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import de.uzk.hki.da.archivers.NativeJavaTarArchiveBuilder;
import de.uzk.hki.da.core.ConfigurationException;
import de.uzk.hki.da.grid.DistributedConversionAdapter;
import de.uzk.hki.da.utils.MD5Checksum;


/**
 * Build the AIP (in tar format and surrounded by bagit container) 
 * from the (partial) object under /da-nrw/fork/(contractor-short-name)/(object-identifier).
 * The package contains two representations underneath the data folder. 
 * One (a) representation with the submitted files. 
 * One (b) representation with the converted files.
 * 
 * Workflow effects:
 * Container gets created as <code>/da-nrw/aip/[csn]/[oid]/[oid].pack_<package_name>.tar.
 * When container has been created the source under fork gets destroyed. <br>
 * 
 * The event log for the package is merged with the premis.xml inside the package before
 * building the TAR.
 * 
 * @author Daniel M. de Oliveira
 * @author Jens Peters
 * @author Thomas Kleinke
 */
public class TarAction extends AbstractAction {
	
	static final Logger logger = LoggerFactory.getLogger(TarAction.class);
	private DistributedConversionAdapter distributedConversionAdapter;
	private String tar = null;
	
	public TarAction(){}
	
	@Override
	boolean implementation() throws IOException {
		if (distributedConversionAdapter==null) throw new ConfigurationException("distributedConversionAdapter not set");
		object.reattach();
		
		tar = localNode.getWorkAreaRootPath() + 
				object.getContractor().getShort_name() + "/" + object.getIdentifier() 
				+ ".pack_" + object.getLatestPackage().getName() + ".tar";
		
		logger.info ( "Building tar for AIP at: " + tar );
		try {
			NativeJavaTarArchiveBuilder builder = new NativeJavaTarArchiveBuilder();
			builder.setFirstLevelEntryName(object.getIdentifier()+".pack_"+object.getLatestPackage().getName());
			builder.setExclusionPattern(   object.getIdentifier()+".pack_"+object.getLatestPackage().getName()+"/dip.*");
			builder.archiveFolder(new File(object.getPath()),new File(tar),true);
			
		} catch (Exception e) {
			throw new RuntimeException("Error while creating tar.",e);
		}

		object.getLatestPackage().setChecksum(MD5Checksum.getMD5checksumForLocalFile(
				new File(tar)));
		return true;
	}

	
	/**
	 * @author Daniel M. de Oliveira
	 */
	@Override
	void rollback() {
		if ((tar!=null)&&new File(tar).exists()){
			logger.info("Deleting previously (possibly only partially) created file "+tar);
			new File(tar).delete();
		}
		logger.info("@Admin: You can safely roll back this job to status "+this.getStartStatus()+" now.");
	}

	public DistributedConversionAdapter getDistributedConversionAdapter() {
		return distributedConversionAdapter;
	}

	public void setDistributedConversionAdapter(
			DistributedConversionAdapter distributedConversionAdapter) {
		this.distributedConversionAdapter = distributedConversionAdapter;
	}
}



