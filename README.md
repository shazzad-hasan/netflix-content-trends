# Analysing Netflix Content Trends

### Overview

The goal of this project is to transform a flat CSV file dataset into a structured and normalized database
and perform exploratory data analysis to address some potential business questions.

### Dataset

The dataset consists of Netflix TV shows and movies as of 2019. It includes the following columns:

- **show_id**:  Unique ID of the movie / TV show
- **title**: Title of the movie / TV show
- **director**: Directors of the movie / TV show
- **cast**: Actors playing in the movie / TV show
- **country**: The country in which the movie / TV show was directed
- **date_added**: The date on which the movie or TV show was added to Netflix
- **release_year**: The year the movie / TV show was releases
- **rating**: The rating of the movie or TV show received
- **duration**: Total length of the movie / TV show
- **listed_in**: The category / genre of the movie or TV show
- **description**: The description / short summary of the movie or TV show

### Database Structure

The database includes several tables, each tables are normalized to minimize redundancy
and enhance data integraty. Each tables represent a distinct aspect of the dataset.

- **movies**: Contains movie/TV show titles and their corresponding unique IDs
- **cast_members**: Contains the names of cast members and their associated IDs
- **directors**: Contains director names and their corresponding IDs
- **genres**: Contains category/genres and their corresponding IDs
- **casting**: Connects shows to their directors and cast members
- **genres_mapping**: Links movies/TV shows to their genres
- **miscellaneous**: Captures miscellaneous details such as type and country
- **movie_descriptions**: Contains movie/show IDs and their corresponding descriptions
- **movie_info**: Contain additional movie/TV show information like duration
- **ratings**: Contains rating description and their respective descriptions
- **ratings_mapping**: Associate shows/movies with their respective ratings
- **time**: Contain movie/TV show IDs and their time related information such as the date on which the movie or TV show was added to Netflix and release year

The **netflix_combined** table is a comprehensive table that integrates data from all the aforementioned tables through SQL joins.

### File Descriptions

- **netflix_import.sql**: Running this file creates the entire database with all the individual tables.  
- **combined_table.sql**: Running this file creates the `netflix_combined` table.  
- **EDA_netflix.sql**: This SQL file contains all the queries written to answer potential business questions.  

### Potential Business Questions:

#### Content Strategy Development
- **Problem**: Identify the most popular genre to guide future content creation and acquisition strategies.
- **Query**: Analyze the distributions of shows/movies across different genres and ratings over time to identify trending categories.

#### Market Analysis
- **Problem**: Analyze the distribution of content across different countries  to optimize marketing strategies.
- **Query**: Identify the types of content that receive the most watch time in each country.

#### Release Timing Analysis
- **Problem**: Determine the optimal time of the year for releasing new content.
- **Query**: Analyze which months have had the highest number of content releases.

#### Director and Cast Analysis
- **Problem**: Identifying the most successful directors and cast members.
- **Query**: Examine past collaborations between directors and cast members that have led to highly rated shows and movies.

#### Viewer Preferences Analysis
- **Problem**: Understand viewer preferences and trands.
- **Query**: Analyze the genres, ratings, and release years of shows and movies to identify trends over time.

#### Content Localization Strategy
- **Problem**: Analyzing content and marketing strategies for specific contries.
- **Query**: Identify most common genres and type of shows/movies for each specific countries.

#### Budget Allocation for New Production
- **Problem**: Identify which type of genres are most likely to succeed and warrant higher investment.
- **Query**: Assess the correlation between genres and their ratings to determine high performing categories.

