package com.skycom.test.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import com.skycom.test.domain.Post;
import com.skycom.test.service.PostService;
import org.springframework.web.bind.annotation.RequestMapping;


@Controller
@RequestMapping("/")
public class PostController {

    @Autowired
    private PostService postService;

    @GetMapping("/")
    public String main(Model model,
                        @RequestParam(name="gender", required=false, defaultValue="") String gender,
                        @RequestParam(name="minAge", required=false, defaultValue="0") int minAge,
                        @RequestParam(name="maxAge", required=false, defaultValue="0") int maxAge,
                        @RequestParam(name="location", required=false, defaultValue="") String location) {

        List<Post> posts = postService.postSelector(gender, minAge, maxAge, location);
        List<String> genders = postService.gendersTypeSelector();
        List<String> locations = postService.locationsTypeSelector();

        model.addAttribute("genders", genders);
        model.addAttribute("locations", locations);
        model.addAttribute("posts", posts);
        return "index";
    }

    @PutMapping("/update")
    public void boardSearch(Model model,
                              @RequestBody Long id,
                              @RequestBody String gender,
                              @RequestBody int age,
                              @RequestBody String location) {
        postService.updatePost(id, gender, age, location);
    }

    @DeleteMapping("/delete")
    public void deletePost(@RequestParam(name="id") Long id) {
        postService.deletePost(id);
    }
}
