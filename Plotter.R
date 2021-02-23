

att1_count <- ads %>% select(att1) %>% group_by(att1) %>% summarise(count = n()) %>% arrange(desc(count))

att2_count <- ads %>% select(att2) %>% group_by(att2) %>% summarise(count = n()) %>% arrange(desc(count))


#plot
ggplot(data = ads, mapping = aes(x = att1, y = att2  ))+
  geom_point()

ggplot(data = ads, mapping = aes(x = att1))+
  geom_histogram(binwidth = 1)


ggplot(data = ads, mapping = aes(x = att2))+
  geom_histogram(binwidth = 1)

ggplot()+
  geom_freqpoly(data = ads,mapping = aes(x = Diff_att1),binwidth = 1)
  

ggplot()+
  geom_freqpoly(data = ads,mapping = aes(x = Diff_att2),binwidth = 1)

ggplot()+
  geom_freqpoly(data = att1_count,mapping = aes(x = count))

ggplot()+
  geom_freqpoly(data = att2_count,mapping = aes(x = count))
