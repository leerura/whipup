package com.whipup.dataimport;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Component;

import java.nio.file.Path;

@Component
@ConditionalOnProperty(name = "whipup.command", havingValue = "import-data")
public class DatasetImportRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DatasetImportRunner.class);

    private final DatasetLoader datasetLoader;
    private final DatasetImportService importService;
    private final ConfigurableApplicationContext applicationContext;
    private final Path dataDirectory;

    public DatasetImportRunner(
        DatasetLoader datasetLoader,
        DatasetImportService importService,
        ConfigurableApplicationContext applicationContext,
        @Value("${whipup.data-directory:data}") String dataDirectory
    ) {
        this.datasetLoader = datasetLoader;
        this.importService = importService;
        this.applicationContext = applicationContext;
        this.dataDirectory = Path.of(dataDirectory);
    }

    @Override
    public void run(ApplicationArguments args) {
        Dataset dataset = datasetLoader.load(dataDirectory);
        DatasetImportService.ImportResult result = importService.synchronize(dataset);

        log.info(
            "Dataset import completed: {} ingredients, {} recipes",
            result.ingredientCount(),
            result.recipeCount()
        );
        SpringApplication.exit(applicationContext);
    }
}
