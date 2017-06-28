### Availability of appropriate data

In general, we have access to all possible data and most of them are stored in Google Bigquery as structured tables. But event data is stored in JSON log documents, so we may need to develop a data cleaning pipeline to deal with it.

Although we got a good opportunity to handle such a great amount of data for elevating MOOCs experience, some challenges are still existent:

- Available data vary from course to course. Some courses have more tables and others have less tables, which makes it challenging to build a dashboard with high scalability to be applied for all courses.

- Documentation is overall poor among most tables. Column description is missing and we will have to improve it.

- Learner survey questions are non-existent in given tables. We may need to scrape question data from course page. However, we are now unable to see some course pages since some courses are closed.  

### Identification of risks and mitigation strategies

1. Final dashboard is not exactly what users actually need.

  - *Strategy:* Iterate fast MVP and show it to instructors then get their feedback, and repeat. Ongoing communication towards CTLT team and MOOC instructor is the key of success in this project to ensure we keep working towards the right direction.

2. We designed similar dashboard features to currents two dashboard (CTLT dashboard and Edx dashboard)

   - *Strategy:* Conduct research on how the current two dashboards display their data and collect client's feedback after using the two dashboards.

3. Our clients are not necessarily statistically savvy.

   - *Strategy:* Design more intuitive and readable dashboards with tabs and linked view for users, which really answers what they are looking for, no matter the big picture or specific detail. Include adequate tool tips in the dashboard user interface.

4. User experience is tarnished when dashboard is presented on mobile device.  

   - *Strategy:* Deeply communicate with instructor about their actual usage scenario and frequency to determine whether the dashboard design should be mobile-friendly.

5. It's hard to find general element pattern between courses since course elements vary a lot between each other.

   - *Strategy:*  Ensure all dashboard features are scalable and applicable for all courses. Avoid only focusing on one specific course or specific pattern.
