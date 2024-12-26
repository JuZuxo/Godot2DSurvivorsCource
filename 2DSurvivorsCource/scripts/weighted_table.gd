class_name weightedTable

var items: Array[Dictionary] = []
var weight_sum = 0

#你建的脚本，他的item是互相独立的，敌人生成器中叫做enemy_table，他们的item互不相通
func add_item(item, weight: int):   #item就是PackedScene
	items.append({"item": item, "weight":weight})
	weight_sum += weight    #老鼠，10  巫师，20  那么weight_sum就是30
	
	
func remove_item(item_to_remove):  #要remove谁就丢进这个函数去
	items = items.filter(func (item): return item["item"] != item_to_remove)
	#不等于item_to_remove的item全部返回
	weight_sum = 0
	for item in items:  #重新计算权重
		weight_sum += item["weight"]

func pick_item(exclude: Array = []):   #pick_item的时候就会在1到30之间挑选
	var adjusted_items : Array[Dictionary] = items
	var adjusted_weight_sum = weight_sum  #exclude就是chosen_upgrade数组
	if exclude.size() > 0:  #chosen_upgrades已经有了一个，就要判定是否挑选技能重复了！
		adjusted_items = []
		adjusted_weight_sum = 0
		for item in items:   #翻阅items数组
			if item["item"] in exclude:  #翻阅exclude数组
				continue  #如果item在exclude中，继续循环判定下一个是否重复，如果不在exclude中。那么就可以添加进adjusted_items
			adjusted_items.append(item)  #此处if用于防止技能被重复抽取
			adjusted_weight_sum += item["weight"]
	
	var chosen_weight = randi_range(1, adjusted_weight_sum)
	var iteration_sum = 0
	for item in adjusted_items:
		iteration_sum += item["weight"]   #iteration_sum就是个中间值表示item["weight"]
		if chosen_weight <= iteration_sum:  #选到5就是老鼠，选到11就是巫师，iteration_sum就是个中间值表示item["weight"]
			return item["item"]  #这个item代表{"item": item, "weight":weight}这个字典
			#item["item"]代表item这个字典的key"item"，返回的将会是一个PackedScene
		
