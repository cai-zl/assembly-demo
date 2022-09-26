package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author cai zl
 * @since 2022/9/26 11:40
 */
@RestController
@RequestMapping("/demo")
public class ExampleController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello";
    }

}

