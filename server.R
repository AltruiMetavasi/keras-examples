# server start ------------------------------------------------------------

function(input, output, session) {

# global reactive ---------------------------------------------------------

  # image input reactive
  img_input <- reactive({

    # resolve input
    if (is.null(input$img)) {

      results <- "data/test/0/img_000001.jpg"

    } else {

      results <- input$img$datapath

    }

    # return the results
    results

  })

  # image prediction
  img_pred <- reactive({

    # prepare image input
    x <- image_load(img_input(), target_size = c(28, 28), grayscale = TRUE) %>%
      image_to_array() %>%
      array_reshape(c(1, dim(.)))

    if (!input$img_mode) {

      x <- 255 - x

    }

    x <- x / 255

    # make prediction
    results <- predict(model, x)

    results <- results %>%
      as_tibble(.name_repair = "universal") %>%
      set_names(classes) %>%
      gather(class, prob) %>%
      arrange(desc(prob)) %>%
      mutate(prob = percent(prob)) %>%
      mutate(text = glue("{class} ({prob})"))

    # return the result
    results

  })

# outputs -----------------------------------------------------------------

  # image output
  output$img_output <- renderPlot({

    image_read(img_input()) %>%
      image_ggplot()

  })

  # prediction output
  output$img_pred_title <- renderUI({

    # get prediction
    img_pred <- img_pred()

    # convert prediction to text
    results <- glue("<h2>Predicted digit: {img_pred$text[1]}</h2>")

    # return the results
    HTML(results)

  })

  output$img_pred_subtitle <- renderUI({

    # get prediction
    img_pred <- img_pred()

    # convert prediction to text
    results <- glue(
      "
      <h4>Another digits probabilities:</h4>
      <h5>{paste(img_pred$text[2:5], collapse = ', ')}</h5>
      <h5>{paste(img_pred$text[6:10], collapse = ', ')}</h5>
      "
    )

    # return the results
    HTML(results)

  })

# server end --------------------------------------------------------------

}
