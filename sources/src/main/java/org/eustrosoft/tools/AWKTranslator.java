package org.eustrosoft.tools;

import java.io.*;


public class AWKTranslator {
	private static final String AWK = "awk";
	private static final String FILE_PARAM = "-f";
	private static final String AWK_FILE_NAME = "/s/www/qr.qxyz.ru/bin/dowiki.awk";
	private static final String SPACE = " ";


	public String doWiki(String path) throws IOException {
		StringBuilder commandBuilder = new StringBuilder();
		commandBuilder.append(AWK).append(SPACE)
					  .append(FILE_PARAM).append(SPACE)
					  .append(AWK_FILE_NAME).append(SPACE)
					  .append(path);
		
		String finalCommand = commandBuilder.toString();
		Process p = Runtime.getRuntime().exec(finalCommand);
		BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
		String str = "";
		StringBuilder output = new StringBuilder();
		while((str = reader.readLine()) != null) {
			output.append(str);
		}
		return output.toString();
	}
/*
	public static void translateFile(String path) {
		StringBuilder commandBuilder = new StringBuilder();
		commandBuilder.append(AWK).append(SPACE)
					  .append(FILE_PARAM).append(SPACE);

		for(int i = 0; i < args.length; i++) {
			commandBuilder.append(args[i]).append(SPACE);
		}

		try {
			String finalCommand = commandBuilder.toString();
			Process p = Runtime.getRuntime().exec(finalCommand);
			BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String str = "";
			while((str = reader.readLine()) != null) {
				System.out.println("Hello:" + str);
			}
		} catch (Exception ex) {
			System.out.println(ex.getMessage());
		}
	}
*/
}
