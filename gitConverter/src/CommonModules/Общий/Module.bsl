#Область СлужебныеПроцедурыИФункции

Процедура РасчитатьДаты(ДатаНачала, ДатаОкончания, ФактДней, ЗадачаПредшественник) Экспорт
	
	Если ЗначениеЗаполнено(ЗадачаПредшественник) Тогда
		
		ДатаНачала = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЗадачаПредшественник, "ДатаОкончания");
		ДатаНачала = УвеличитьДатуНаКоличествоРабочихДней(ДатаНачала, 2);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ДатаНачала) Тогда
		
		ДатаНачала = НачалоДня(ТекущаяДатаСеанса());
		
	КонецЕсли;
	
	ДатаОкончания = УвеличитьДатуНаКоличествоРабочихДней(ДатаНачала, ФактДней);
	
КонецПроцедуры

Функция УвеличитьДатуНаКоличествоРабочихДней(ДатаОтсчета, КоличествоДней) Экспорт
	
	КоличествоРабочихДней = ?(КоличествоДней = 0, 0, КоличествоДней -1);
	
	ДатаРезультат = ДатаОтсчета;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ОсновнойКалендарьПредприятия.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ AX_ВтКалендари
		|ИЗ
		|	Справочник.Календари КАК ОсновнойКалендарьПредприятия
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТекущийГод.Календарь КАК Календарь,
		|	ТекущийГод.ДатаГрафика КАК ДатаГрафика,
		|	ТекущийГод.ДеньВключенВГрафик КАК ДеньВключенВГрафик,
		|	ТекущийГод.КоличествоДнейВГрафикеСНачалаГода КАК КоличествоДнейВГрафике
		|ПОМЕСТИТЬ AX_ВтКалендарныйГрафик
		|ИЗ
		|	РегистрСведений.КалендарныеГрафики КАК ТекущийГод
		|ГДЕ
		|	ТекущийГод.ДатаГрафика >= НАЧАЛОПЕРИОДА(&ДатаОтсчета, ДЕНЬ)
		|	И ТекущийГод.ДатаГрафика <= ДОБАВИТЬКДАТЕ(&ДатаОтсчета, МЕСЯЦ, 6)
		|	И ТекущийГод.Год = ГОД(&ДатаОтсчета)
		|	И ТекущийГод.Календарь В
		|			(ВЫБРАТЬ
		|				AX_ВтКалендари.Ссылка
		|			ИЗ
		|				AX_ВтКалендари КАК AX_ВтКалендари)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СледующийГод.Календарь,
		|	СледующийГод.ДатаГрафика,
		|	СледующийГод.ДеньВключенВГрафик,
		|	СледующийГод.КоличествоДнейВГрафикеСНачалаГода + ТекущийГод.КоличествоДнейВГрафикеСНачалаГода
		|ИЗ
		|	РегистрСведений.КалендарныеГрафики КАК СледующийГод
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.КалендарныеГрафики КАК ТекущийГод
		|		ПО (ТекущийГод.ДатаГрафика = НАЧАЛОПЕРИОДА(КОНЕЦПЕРИОДА(&ДатаОтсчета, ГОД), ДЕНЬ))
		|			И (ТекущийГод.Календарь = СледующийГод.Календарь)
		|ГДЕ
		|	СледующийГод.Год = ГОД(ДОБАВИТЬКДАТЕ(&ДатаОтсчета, ГОД, 1))
		|	И СледующийГод.ДатаГрафика <= ДОБАВИТЬКДАТЕ(&ДатаОтсчета, МЕСЯЦ, 6)
		|	И СледующийГод.Календарь В
		|			(ВЫБРАТЬ
		|				AX_ВтКалендари.Ссылка
		|			ИЗ
		|				AX_ВтКалендари КАК AX_ВтКалендари)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Календарь,
		|	ДатаГрафика,
		|	КоличествоДнейВГрафике
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	AX_ВтКалендарныйГрафик.Календарь КАК Календарь,
		|	AX_ВтКалендарныйГрафик.ДатаГрафика КАК ДатаГрафика,
		|	AX_ВтКалендарныйГрафик.ДеньВключенВГрафик КАК ДеньВключенВГрафик,
		|	AX_ВтКалендарныйГрафик.КоличествоДнейВГрафике КАК КоличествоДнейВГрафике,
		|	ВЫБОР
		|		КОГДА AX_ВтКалендарныйГрафик.ДеньВключенВГрафик
		|			ТОГДА AX_ВтКалендарныйГрафик.КоличествоДнейВГрафике + &КоличествоДней
		|		ИНАЧЕ AX_ВтКалендарныйГрафик.КоличествоДнейВГрафике + 1 + &КоличествоДней
		|	КОНЕЦ КАК НовоеКоличествоДнейВГрафике
		|ПОМЕСТИТЬ ВТ_НовоеКоличествоДнейВГрафике
		|ИЗ
		|	AX_ВтКалендарныйГрафик КАК AX_ВтКалендарныйГрафик
		|ГДЕ
		|	AX_ВтКалендарныйГрафик.ДатаГрафика = НАЧАЛОПЕРИОДА(&ДатаОтсчета, ДЕНЬ)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МИНИМУМ(AX_ВтКалендарныйГрафик.ДатаГрафика) КАК Дата
		|ИЗ
		|	ВТ_НовоеКоличествоДнейВГрафике КАК ВТ_НовоеКоличествоДнейВГрафике
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ AX_ВтКалендарныйГрафик КАК AX_ВтКалендарныйГрафик
		|		ПО (AX_ВтКалендарныйГрафик.КоличествоДнейВГрафике = ВТ_НовоеКоличествоДнейВГрафике.НовоеКоличествоДнейВГрафике)";
	
	Запрос.УстановитьПараметр("ДатаОтсчета", ДатаОтсчета);
	Запрос.УстановитьПараметр("КоличествоДней", КоличествоРабочихДней);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДатаРезультат = ВыборкаДетальныеЗаписи.Дата;
	КонецЦикла;
	
	Возврат ДатаРезультат;
	
КонецФункции

Функция ПолучитьВыходныеЗаПериод() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МИНИМУМ(Задачи.ДатаНачала) КАК ДатаНачала,
		|	МАКСИМУМ(Задачи.ДатаОкончания) КАК ДатаОкончания
		|ПОМЕСТИТЬ ВТ_ДатыЗадач
		|ИЗ
		|	Документ.Задачи КАК Задачи
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ОсновнойКалендарьПредприятия.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ AX_ВтКалендари
		|ИЗ
		|	Справочник.Календари КАК ОсновнойКалендарьПредприятия
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТекущийГод.Календарь КАК Календарь,
		|	ТекущийГод.ДатаГрафика КАК ДатаГрафика,
		|	ТекущийГод.ДеньВключенВГрафик КАК ДеньВключенВГрафик,
		|	ТекущийГод.КоличествоДнейВГрафикеСНачалаГода КАК КоличествоДнейВГрафике
		|ИЗ
		|	РегистрСведений.КалендарныеГрафики КАК ТекущийГод,
		|	ВТ_ДатыЗадач КАК ВТ_ДатыЗадач
		|ГДЕ
		|	ТекущийГод.ДатаГрафика >= НАЧАЛОПЕРИОДА(ВТ_ДатыЗадач.ДатаНачала, МЕСЯЦ)
		|	И ТекущийГод.ДатаГрафика <= КОНЕЦПЕРИОДА(ВТ_ДатыЗадач.ДатаОкончания, МЕСЯЦ)
		|	И НЕ ТекущийГод.ДеньВключенВГрафик
		|
		|УПОРЯДОЧИТЬ ПО
		|	ДатаГрафика";
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатЗапроса;


КонецФункции 

#КонецОбласти