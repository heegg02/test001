package com.skycom.test.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.skycom.test.domain.Post;

@Service
public class ExelService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public ByteArrayResource xlsxBuilder(List<Post> posts) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Posts");
        Row headerRow = sheet.createRow(0);
        headerRow.createCell(0).setCellValue("id");
        headerRow.createCell(1).setCellValue("gender");
        headerRow.createCell(2).setCellValue("age");
        headerRow.createCell(3).setCellValue("location");
        for (int i = 0; i < posts.size(); i++) {
            Post post = posts.get(i);
            Row row = sheet.createRow(i + 1);
            row.createCell(0).setCellValue(post.getId());
            row.createCell(1).setCellValue(post.getGender());
            row.createCell(2).setCellValue(post.getAge());
            row.createCell(3).setCellValue(post.getLocation());
        }

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        workbook.write(out);
        workbook.close();

        ByteArrayResource resource = new ByteArrayResource(out.toByteArray());
        return resource;
    }

    public void fileUpload(MultipartFile file) throws IOException {
        InputStream is = file.getInputStream();
        Workbook workbook = new XSSFWorkbook(is);
        Sheet sheet = workbook.getSheetAt(0);

        jdbcTemplate.execute("DELETE FROM post;");
        jdbcTemplate.execute("ALTER TABLE post AUTO_INCREMENT = 0;");

        boolean isHeader = true;
        for (Row row : sheet) {
            if (isHeader) {
                isHeader = false;
                continue;
            }
            
            long id = (long) row.getCell(0).getNumericCellValue();
            String gender = row.getCell(1).getStringCellValue();
            int age = (int) row.getCell(2).getNumericCellValue();
            String location = row.getCell(3).getStringCellValue();
            jdbcTemplate.update("INSERT INTO post (id, gender, age, location) VALUES (?, ?, ?, ?)",
                                id, gender, age, location);
        }
        workbook.close();
    }
}