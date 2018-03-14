FROM java:8-jdk
ADD /selenium /opt/selenium
ADD functions /opt/bin/functions
ADD startGrid /opt/bin/startGrid
RUN chmod +x /opt/bin/startGrid
CMD ["/opt/bin/startGrid"]
