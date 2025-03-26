///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПроверитьМестоположениеКомпоненты(Идентификатор, Местоположение) Экспорт
	
	Если СтрНачинаетсяС(Местоположение, "e1cib/data/Справочник.ВнешниеКомпоненты.ХранилищеКомпоненты") Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ВнешниеКомпонентыВМоделиСервиса") Тогда
		МодульВнешниеКомпонентыВМоделиСервисаСлужебныйКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ВнешниеКомпонентыВМоделиСервисаСлужебныйКлиент");
		Если МодульВнешниеКомпонентыВМоделиСервисаСлужебныйКлиент.ЭтоКомпонентаИзХранилища(Местоположение) Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" в клиентском приложении
		           |по причине:
		           |указано некорректное местоположение внешней компоненты
		           |%2'"),
		Идентификатор, Местоположение);

КонецПроцедуры

// Параметры:
//  Оповещение - ОписаниеОповещения
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Процедура ПроверитьДоступностьКомпоненты(Оповещение, Контекст) Экспорт
	
	ПутьКМакетуДляПоискаПоследнейВерсии = Неопределено;
	ИскатьКомпонентуПоследнейВерсии = ЗначениеЗаполнено(Контекст.ИсходноеМестоположение) И Не Контекст.ВыполненПоискНовойВерсии; 
	Если ИскатьКомпонентуПоследнейВерсии Тогда
		ПутьКМакетуДляПоискаПоследнейВерсии = Контекст.ИсходноеМестоположение;
	КонецЕсли;
	
	Информация = ВнешниеКомпонентыСлужебныйВызовСервера.ИнформацияОСохраненнойКомпоненте(
		Контекст.Идентификатор, Контекст.Версия, ПутьКМакетуДляПоискаПоследнейВерсии);
	
	Контекст.Местоположение = Информация.Местоположение;
	
	// Информация.Состояние:
	// * НеНайдена
	// * НайденаВХранилище
	// * НайденаВОбщемХранилище
	// * ОтключенаАдминистратором
	
	Результат = РезультатДоступностиКомпоненты();
	Результат.КомпонентаПоследнейВерсии = Информация.ПоследняяВерсияКомпонентыИзМакета;
	Результат.Местоположение = Информация.Местоположение;
	
	Если Информация.Состояние = "ОтключенаАдминистратором" Тогда 
		
		Результат.ОписаниеОшибки = НСтр("ru = 'Отключена администратором.'");
		ВыполнитьОбработкуОповещения(Оповещение, Результат);
		
	ИначеЕсли Информация.Состояние = "НеНайдена" Тогда 
		
		Если Информация.ДоступнаЗагрузкаСПортала 
			И Контекст.ПредложитьЗагрузить Тогда 
			
			КонтекстПоиска = Новый Структура;
			КонтекстПоиска.Вставить("Оповещение", Оповещение);
			КонтекстПоиска.Вставить("Контекст", Контекст);
			
			ОповещениеФормы = Новый ОписаниеОповещения(
				"ПроверитьДоступностьКомпонентыПослеПоискаКомпонентыНаПортале",
				ЭтотОбъект, 
				КонтекстПоиска);
				
			Оповещение = Новый ОписаниеОповещения("ПоискКомпонентыНаПорталеПриФормированииРезультата", ЭтотОбъект, ОповещениеФормы);
			ВнешниеКомпонентыКлиентЛокализация.ПоискКомпонентыНаПортале(Оповещение, Контекст);
			
		Иначе 
			Результат.ОписаниеОшибки = НСтр("ru = 'Компонента отсутствует в списке разрешенных внешних компонент.'");
			ВыполнитьОбработкуОповещения(Оповещение, Результат);
		КонецЕсли;
		
	Иначе
		
		Результат.Вставить("Версия", Информация.Реквизиты.Версия);
			
		Если ИскатьКомпонентуПоследнейВерсии Тогда
			
			ЗаменитьНаАктуальнуюКомпонентуИзСправочника(Результат, Контекст.Идентификатор, Информация.Местоположение);
			
		КонецЕсли;
		
		
		Если Не Информация.ЗаполненыЦелевыеПлатформы Или ТекущийКлиентПоддерживаетсяКомпонентой(Информация.Реквизиты.ЦелевыеПлатформы) Тогда
			
			Результат.Доступна = Истина;
			ВыполнитьОбработкуОповещения(Оповещение, Результат);
			
		Иначе 
			
			ПараметрыОповещения = Новый Структура;
			ПараметрыОповещения.Вставить("Оповещение", Оповещение);
			ПараметрыОповещения.Вставить("Результат", Результат);
			
			ОповещениеФормы = Новый ОписаниеОповещения(
				"ПроверитьДоступностьКомпонентыПослеОтображенияДоступныхВидовКлиентов",
				ЭтотОбъект,
				ПараметрыОповещения);
				
			Если Не Контекст.ПредложитьУстановить Тогда
				ВыполнитьОбработкуОповещения(ОповещениеФормы, Ложь);
				Возврат;
			КонецЕсли;
			
			ПараметрыФормы = Новый Структура;
			ПараметрыФормы.Вставить("ТекстПояснения", Контекст.ТекстПояснения);
			ПараметрыФормы.Вставить("ПоддерживаемыеКлиенты", Информация.Реквизиты.ЦелевыеПлатформы);
			
			ОткрытьФорму("ОбщаяФорма.УстановкаВнешнейКомпонентыНевозможна",
				ПараметрыФормы,,,,, ОповещениеФормы);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Параметры:
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Асинх Функция РезультатПроверкиДоступностиКомпоненты(Контекст) Экспорт
	
	ПутьКМакетуДляПоискаПоследнейВерсии = Неопределено;
	ИскатьКомпонентуПоследнейВерсии = ЗначениеЗаполнено(Контекст.ИсходноеМестоположение) И Не Контекст.ВыполненПоискНовойВерсии; 
	Если ИскатьКомпонентуПоследнейВерсии Тогда
		ПутьКМакетуДляПоискаПоследнейВерсии = Контекст.ИсходноеМестоположение;
	КонецЕсли;
	
	Информация = ВнешниеКомпонентыСлужебныйВызовСервера.ИнформацияОСохраненнойКомпоненте(
		Контекст.Идентификатор, Контекст.Версия, ПутьКМакетуДляПоискаПоследнейВерсии);
	
	Контекст.Местоположение = Информация.Местоположение;
	
	// Информация.Состояние:
	// * НеНайдена
	// * НайденаВХранилище
	// * НайденаВОбщемХранилище
	// * ОтключенаАдминистратором
	
	Результат = РезультатДоступностиКомпоненты();
	Результат.КомпонентаПоследнейВерсии = Информация.ПоследняяВерсияКомпонентыИзМакета;
	Результат.Местоположение = Информация.Местоположение;
	
	Если Информация.Состояние = "ОтключенаАдминистратором" Тогда 
		
		Результат.ОписаниеОшибки = НСтр("ru = 'Отключена администратором.'");
		Возврат Результат;
		
	ИначеЕсли Информация.Состояние = "НеНайдена" Тогда 
		
		Результат.ОписаниеОшибки = НСтр("ru = 'Компонента отсутствует в списке разрешенных внешних компонент.'");
		
		Возврат Результат;
		
	Иначе
		
		Результат.Вставить("Версия", Информация.Реквизиты.Версия);
			
		Если ИскатьКомпонентуПоследнейВерсии Тогда
			
			ЗаменитьНаАктуальнуюКомпонентуИзСправочника(Результат, Контекст.Идентификатор, Информация.Местоположение)
						
		КонецЕсли;
		
		Если Не Информация.ЗаполненыЦелевыеПлатформы Или ТекущийКлиентПоддерживаетсяКомпонентой(Информация.Реквизиты.ЦелевыеПлатформы) Тогда
			
			Результат.Доступна = Истина;
			Возврат Результат;
		
		Иначе
			
			ОписаниеОшибки = СтроковыеФункцииКлиент.ФорматированнаяСтрока(
				НСтр("ru = 'Не предусмотрена работа внешней компоненты 
					 |в клиентском приложении <b>%1</b>.
					 |Обратитесь к разработчику внешней компоненты.'"), ПредставлениеТекущегоКлиента());

			Если Не Контекст.ПредложитьУстановить Тогда
				Результат.Доступна = Ложь;
				Результат.ОписаниеОшибки = ОписаниеОшибки;
			Иначе
				КнопкиВопроса = Новый СписокЗначений;
				КнопкиВопроса.Добавить("Закрыть", НСтр("ru = 'Закрыть'"));
				КнопкиВопроса.Добавить("ПродолжитьПопыткуУстановки", НСтр("ru = 'Продолжить попытку установки'"));

				ЗаголовокВопроса = Контекст.ТекстПояснения;
				Если ПустаяСтрока(ЗаголовокВопроса) Тогда
					ЗаголовокВопроса = НСтр("ru = 'Установка внешней компоненты невозможна.'");
				КонецЕсли;

				Ответ = Ждать ВопросАсинх(ОписаниеОшибки, КнопкиВопроса,, "Закрыть", ЗаголовокВопроса);

				Если Ответ = "ПродолжитьПопыткуУстановки" Тогда
					Результат.Доступна = Истина;
				Иначе
					Результат.Доступна = Ложь;
					Результат.ОписаниеОшибки = ОписаниеОшибки;
				КонецЕсли;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// См. СтандартныеПодсистемыКлиент.ПриПолученииСерверногоОповещения
Процедура ПриПолученииСерверногоОповещения(ИмяОповещения, Результат) Экспорт
	
	Если ИмяОповещения <> "СтандартныеПодсистемы.ВнешниеКомпоненты" Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПриложения.Вставить("СтандартныеПодсистемы.ВнешниеКомпоненты.СимволическиеИмена",
		Новый ФиксированноеСоответствие(Новый Соответствие));
	
	ПараметрыПриложения.Вставить("СтандартныеПодсистемы.ВнешниеКомпоненты.Объекты",
		Новый ФиксированноеСоответствие(Новый Соответствие));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПроверитьДоступностьКомпоненты

Процедура ПроверитьДоступностьКомпонентыПослеПоискаКомпонентыНаПортале(Загружена, КонтекстПоиска) Экспорт
	
	Оповещение = КонтекстПоиска.Оповещение;
	Контекст   = КонтекстПоиска.Контекст;
	
	Если Загружена Тогда
		Контекст.ПредложитьЗагрузить = Ложь;
		ПроверитьДоступностьКомпоненты(Оповещение, Контекст);
	Иначе 
		ВыполнитьОбработкуОповещения(Оповещение, РезультатДоступностиКомпоненты());
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьДоступностьКомпонентыПослеОтображенияДоступныхВидовКлиентов(Результат, Контекст) Экспорт
	
	РезультатДоступностиКомпоненты = Контекст.Результат;
	РезультатДоступностиКомпоненты.Доступна = Результат = Истина;
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, РезультатДоступностиКомпоненты);
	
КонецПроцедуры

// Возвращаемое значение:
//  Структура:
//   * Доступна - Булево
//   * Версия - Строка
//   * КомпонентаПоследнейВерсии - см. СтандартныеПодсистемыСервер.КомпонентаПоследнейВерсии
//   * ОписаниеОшибки - Строка
//   * Местоположение - Строка
//
Функция РезультатДоступностиКомпоненты() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Доступна", Ложь);
	Результат.Вставить("Версия", "");
	Результат.Вставить("КомпонентаПоследнейВерсии", Неопределено);
	Результат.Вставить("ОписаниеОшибки", "");
	Результат.Вставить("Местоположение", "");
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаменитьНаАктуальнуюКомпонентуИзСправочника(Результат, Идентификатор, Местоположение)
	
	Если СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(СтрЗаменить(Результат.Версия, ".", "")) Тогда
		ЧастиВерсии = СтрРазделить(Результат.Версия, ".");
		Если ЧастиВерсии.Количество() = 4 И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(Результат.Версия,
			Результат.КомпонентаПоследнейВерсии.Версия) <= 0 Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
		
	// Используется компонента из справочника, если ее версия больше, чем версия макета, или не соответствует шаблону.
	Результат.КомпонентаПоследнейВерсии = Новый Структура("Идентификатор, Версия, Местоположение", Идентификатор,
		Результат.Версия, Местоположение);
		
КонецПроцедуры

// Текущий клиент поддерживается компонентой.
// 
// Параметры:
//  Реквизиты - см. ВнешниеКомпонентыСлужебный.РеквизитыКомпоненты
// 
// Возвращаемое значение:
//  Булево - текущий клиент поддерживается компонентой
//
Функция ТекущийКлиентПоддерживаетсяКомпонентой(Реквизиты)
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	Браузер = Неопределено;
#Если ВебКлиент Тогда
	Строка = СистемнаяИнформация.ИнформацияПрограммыПросмотра;
	Если СтрНайти(Строка, "YaBrowser/") > 0 Тогда
		Браузер = "ЯндексБраузер";
	ИначеЕсли СтрНайти(Строка, "Chrome/") > 0 Тогда
		Браузер = "Chrome";
	ИначеЕсли СтрНайти(Строка, "MSIE") > 0 Тогда
		Браузер = "MSIE";
	ИначеЕсли СтрНайти(Строка, "Safari/") > 0 Тогда
		Браузер = "Safari";
	ИначеЕсли СтрНайти(Строка, "Firefox/") > 0 Тогда
		Браузер = "Firefox";
	КонецЕсли;
#КонецЕсли

	ИмяТипаПлатформы = ОбщегоНазначенияКлиентСервер.ИмяТипаПлатформы(СистемнаяИнформация.ТипПлатформы);
	
	Если ИмяТипаПлатформы = "Linux_x86" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Linux_x86;
		КонецЕсли;
		
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Linux_x86_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Linux_x86_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Linux_x86_ЯндексБраузер;
		КонецЕсли;
	
	ИначеЕсли ИмяТипаПлатформы = "Linux_x86_64" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Linux_x86_64;
		КонецЕсли;
		
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Linux_x86_64_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Linux_x86_64_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Linux_x86_64_ЯндексБраузер;
		КонецЕсли;
	
	ИначеЕсли ИмяТипаПлатформы = "MacOS_x86_64" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.MacOS_x86_64;
		КонецЕсли;
		
		Если Браузер = "Safari" Тогда
			Возврат Реквизиты.MacOS_x86_64_Safari;
		КонецЕсли;
		
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.MacOS_x86_64_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.MacOS_x86_64_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.MacOS_x86_64_ЯндексБраузер;
		КонецЕсли;
	
	ИначеЕсли ИмяТипаПлатформы = "Windows_x86" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Windows_x86;
		КонецЕсли;
		
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Windows_x86_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Windows_x86_Chrome;
		КонецЕсли;
		
		Если Браузер = "MSIE" Тогда
			Возврат Реквизиты.Windows_x86_MSIE;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Windows_x86_ЯндексБраузер;
		КонецЕсли;
		
	ИначеЕсли ИмяТипаПлатформы = "Windows_x86_64" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Windows_x86_64;
		КонецЕсли;
		
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Windows_x86_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Windows_x86_Chrome;
		КонецЕсли;
		
		Если Браузер = "MSIE" Тогда
			Возврат Реквизиты.Windows_x86_64_MSIE;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Windows_x86_64_ЯндексБраузер;
		КонецЕсли;
	
	ИначеЕсли ИмяТипаПлатформы = "MacOS_x86" Тогда
		// В браузере может быть неправильно определен тип платформы.
	
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.MacOS_x86_64_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.MacOS_x86_64_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.MacOS_x86_64_ЯндексБраузер;
		КонецЕсли;
		
	ИначеЕсли ИмяТипаПлатформы = "Linux_E2K" Тогда
		
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Linux_E2K;
		КонецЕсли;
	
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Linux_E2K_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Linux_E2K_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Linux_E2K_ЯндексБраузер;
		КонецЕсли;
		
	ИначеЕсли ИмяТипаПлатформы = "Linux_ARM64" Тогда
	
		Если Браузер = Неопределено Тогда
			Возврат Реквизиты.Linux_ARM64;
		КонецЕсли;
	
		Если Браузер = "Firefox" Тогда
			Возврат Реквизиты.Linux_ARM64_Firefox;
		КонецЕсли;
		
		Если Браузер = "Chrome" Тогда
			Возврат Реквизиты.Linux_ARM64_Chrome;
		КонецЕсли;
		
		Если Браузер = "ЯндексБраузер" Тогда
			Возврат Реквизиты.Linux_ARM64_ЯндексБраузер;
		КонецЕсли;
		
	ИначеЕсли ИмяТипаПлатформы = "iOS_ARM" Тогда
	
		Возврат Реквизиты.iOS_ARM;
	
	ИначеЕсли ИмяТипаПлатформы = "iOS_ARM64" Тогда
	
		Возврат Реквизиты.iOS_ARM64;
	
	ИначеЕсли ИмяТипаПлатформы = "Android_ARM" Тогда
	
		Возврат Реквизиты.Android_ARM;
	
	ИначеЕсли ИмяТипаПлатформы = "Android_ARM_64" Тогда
	
		Возврат Реквизиты.Android_ARM64;
		
	ИначеЕсли ИмяТипаПлатформы = "Android_x86" Тогда
	
		Возврат Реквизиты.Android_x86;
		
	ИначеЕсли ИмяТипаПлатформы = "Android_x86_64" Тогда
	
		Возврат Реквизиты.Android_x86_64;
		
	ИначеЕсли ИмяТипаПлатформы = "WinRT_ARM" Тогда
	
		Возврат Реквизиты.WindowsRT_ARM;
		
	ИначеЕсли ИмяТипаПлатформы = "WinRT_x86" Тогда
	
		Возврат Реквизиты.WindowsRT_x86;
		
	ИначеЕсли ИмяТипаПлатформы = "WinRT_x86_64" Тогда
	
		Возврат Реквизиты.WindowsRT_x86_64;
	
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ТекстУстановкаВнешнейКомпонентыНевозможна(Знач ТекстПояснения) Экспорт

	Если ПустаяСтрока(ТекстПояснения) Тогда
		ТекстПояснения = НСтр("ru = 'Установка внешней компоненты невозможна.'");
	КонецЕсли;

	Возврат СтроковыеФункцииКлиент.ФорматированнаяСтрока(НСтр("ru = '%1
			  |
			  |Не предусмотрена работа внешней компоненты 
			  |в клиентском приложении <b>%2</b>.
			  |Используйте <a href = about:blank>поддерживаемое клиентское приложение</a> или обратитесь к разработчику внешней компоненты.'"),
		ТекстПояснения, ПредставлениеТекущегоКлиента());
		
КонецФункции

Функция ПредставлениеТекущегоКлиента() 
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	
#Если ВебКлиент Тогда
	Строка = СистемнаяИнформация.ИнформацияПрограммыПросмотра;
	
	Если СтрНайти(Строка, "YaBrowser/") > 0 Тогда
		Браузер = НСтр("ru = 'Яндекс Браузер'");
	ИначеЕсли СтрНайти(Строка, "Chrome/") > 0 Тогда
		Браузер = НСтр("ru = 'Chrome'");
	ИначеЕсли СтрНайти(Строка, "MSIE") > 0 Тогда
		Браузер = НСтр("ru = 'Internet Explorer'");
	ИначеЕсли СтрНайти(Строка, "Safari/") > 0 Тогда
		Браузер = НСтр("ru = 'Safari'");
	ИначеЕсли СтрНайти(Строка, "Firefox/") > 0 Тогда
		Браузер = НСтр("ru = 'Firefox'");
	КонецЕсли;
	
	Приложение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'веб-клиент %1'"), Браузер);
#ИначеЕсли МобильноеПриложениеКлиент Тогда
	Приложение = НСтр("ru = 'мобильное приложение'");
#ИначеЕсли МобильныйКлиент Тогда
	Приложение = НСтр("ru = 'мобильный клиент'");
#ИначеЕсли ТонкийКлиент Тогда
	Приложение = НСтр("ru = 'тонкий клиент'");
#ИначеЕсли ТолстыйКлиентОбычноеПриложение Тогда
	Приложение = НСтр("ru = 'толстый клиент (обычное приложение)'");
#ИначеЕсли ТолстыйКлиентУправляемоеПриложение Тогда
	Приложение = НСтр("ru = 'толстый клиент'");
#КонецЕсли

	ИмяТипаПлатформы = ОбщегоНазначенияКлиентСервер.ИмяТипаПлатформы(СистемнаяИнформация.ТипПлатформы);
	Если ИмяТипаПлатформы = "Windows_x86" Тогда
		Платформа = НСтр("ru = 'Windows x86'");
	ИначеЕсли ИмяТипаПлатформы = "Windows_x86_64" Тогда
		Платформа = НСтр("ru = 'Windows x86-64'");
	ИначеЕсли ИмяТипаПлатформы = "Linux_x86" Тогда
		Платформа = НСтр("ru = 'Linux x86'");
	ИначеЕсли ИмяТипаПлатформы = "Linux_x86_64" Тогда
		Платформа = НСтр("ru = 'Linux x86-64'");
	ИначеЕсли ИмяТипаПлатформы = "MacOS_x86" Тогда
		Платформа = НСтр("ru = 'macOS x86'");
	ИначеЕсли ИмяТипаПлатформы = "MacOS_x86_64" Тогда
		Платформа = НСтр("ru = 'macOS x86-64'");
	ИначеЕсли ИмяТипаПлатформы = "Linux_ARM64" Тогда
		Платформа = НСтр("ru = 'Linux ARM64'");
	ИначеЕсли ИмяТипаПлатформы = "Linux_E2K" Тогда
		Платформа = НСтр("ru = 'Linux E2K'");
	ИначеЕсли ИмяТипаПлатформы = "Android_ARM" Тогда
		Платформа = НСтр("ru = 'Android ARM'");
	ИначеЕсли ИмяТипаПлатформы = "Android_ARM_64" Тогда
		Платформа = НСтр("ru = 'Android_ARM64'");
	ИначеЕсли ИмяТипаПлатформы = "Android_x86" Тогда
		Платформа = НСтр("ru = 'Android x86'");
	ИначеЕсли ИмяТипаПлатформы = "Android_x86_64" Тогда
		Платформа = НСтр("ru = 'Android x86-64'");
	ИначеЕсли ИмяТипаПлатформы = "iOS_ARM" Тогда
		Платформа = НСтр("ru = 'iOS ARM'");
	ИначеЕсли ИмяТипаПлатформы = "iOS_ARM_64" Тогда
		Платформа = НСтр("ru = 'iOS ARM64'");
	ИначеЕсли ИмяТипаПлатформы = "WinRT_ARM" Тогда
		Платформа = НСтр("ru = 'WinRT ARM'");
	ИначеЕсли ИмяТипаПлатформы = "WinRT_x86" Тогда
		Платформа = НСтр("ru = 'WinRT x86'");
	ИначеЕсли ИмяТипаПлатформы = "WinRT_x86_64" Тогда
		Платформа = НСтр("ru = 'WinRT x86-64'");
	КонецЕсли;
	
	// Например:
	// веб-клиент Firefox Windows x86
	// тонкий клиент Windows x86-64
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 %2'"), Приложение, Платформа);
	
КонецФункции

#КонецОбласти

#Область ПодключитьКомпоненту

// Параметры:
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Асинх Функция ПодключитьКомпонентуАсинх(Контекст) Экспорт 
	
	Результат = Ждать РезультатПроверкиДоступностиКомпоненты(Контекст);
	
	Если Результат.Доступна Тогда 
		Возврат Ждать ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуАсинх(Контекст);
	Иначе
		Если Не ПустаяСтрока(Результат.ОписаниеОшибки) Тогда 
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
				           |из хранилища внешних компонент
				           |по причине:
				           |%2'"),
				Контекст.Идентификатор,
				Результат.ОписаниеОшибки);
		КонецЕсли;
		
		Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаПодключенияКомпоненты(ТекстОшибки);
		
	КонецЕсли;
	
КонецФункции

Процедура ПодключитьКомпоненту(Контекст) Экспорт 
	
	Оповещение = Новый ОписаниеОповещения(
		"ПодключитьКомпонентуПослеПроверкиДоступности", 
		ЭтотОбъект, 
		Контекст);
	
	ПроверитьДоступностьКомпоненты(Оповещение, Контекст);
	
КонецПроцедуры

// Параметры:
//  Результат - Структура - результат подключения компоненты:
//    * Подключено - Булево - признак подключения;
//    * ПодключаемыйМодуль - ОбъектВнешнейКомпоненты - экземпляр объекта внешней компоненты.
//    * ОписаниеОшибки - Строка - краткое описание ошибки. При отмене пользователем пустая строка
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Процедура ПодключитьКомпонентуПослеПроверкиДоступности(Результат, Контекст) Экспорт
	
	Если Результат.Доступна Тогда 
		ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпоненту(Контекст);
	Иначе
		Если Не ПустаяСтрока(Результат.ОписаниеОшибки) Тогда 
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
				           |из хранилища внешних компонент
				           |по причине:
				           |%2'"),
				Контекст.Идентификатор,
				Результат.ОписаниеОшибки);
		КонецЕсли;
		
		ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ПодключитьКомпонентуИзРеестраWindows

// Возвращаемое значение:
//  Структура:
//   * Оповещение - ОписаниеОповещения
//   * Идентификатор - Строка
//   * ИдентификаторСозданияОбъекта - Строка
//
Функция КонтекстПодключенияКомпонентыИзРеестраWindows() Экспорт
	
	Контекст = Новый Структура;
	Контекст.Вставить("Оповещение", Неопределено);
	Контекст.Вставить("Идентификатор", "");
	Контекст.Вставить("ИдентификаторСозданияОбъекта", "");
	Возврат Контекст;
		
КонецФункции

// Для вызова из ВнешниеКомпонентыКлиент.ПодключитьКомпонентуИзРеестраWindowsАсинх.
// 
// Параметры:
//  Контекст - см. КонтекстПодключенияКомпонентыИзРеестраWindows.
//
Асинх Функция ПодключитьКомпонентуИзРеестраWindowsАсинх(Контекст) Экспорт
	
	Если ПодключитьКомпонентуИзРеестраWindowsДоступноПодключение() Тогда
		
		Попытка
			
			Подключено = Ждать ПодключитьВнешнююКомпонентуАсинх("AddIn." + Контекст.Идентификатор);
			
		Исключение
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
					 |из реестра Windows
					 |по причине:
					 |%2'"), Контекст.Идентификатор, ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));

			Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаПодключенияКомпоненты(ТекстОшибки);
		КонецПопытки;
		
		Если Подключено Тогда

			ИдентификаторСозданияОбъекта = Контекст.ИдентификаторСозданияОбъекта;

			Если ИдентификаторСозданияОбъекта = Неопределено Тогда
				ИдентификаторСозданияОбъекта = Контекст.Идентификатор;
			КонецЕсли;

			Попытка
				ПодключаемыйМодуль = Новый ("AddIn." + ИдентификаторСозданияОбъекта);
				Если ПодключаемыйМодуль = Неопределено Тогда
					ВызватьИсключение НСтр("ru = 'Оператор Новый вернул Неопределено'");
				КонецЕсли;
			Исключение
				ПодключаемыйМодуль = Неопределено;
				ТекстОшибки = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			КонецПопытки;

			Если ПодключаемыйМодуль = Неопределено Тогда

				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось создать объект внешней компоненты ""%1"", подключенной на клиенте
					 |из реестра Windows,
					 |по причине:
					 |%2'"), Контекст.Идентификатор, ТекстОшибки);

				Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаПодключенияКомпоненты(ТекстОшибки);

			Иначе
				
				Результат = ОбщегоНазначенияСлужебныйКлиент.РезультатПодключенияКомпоненты();
				Результат.Подключено = Истина;
				Результат.ПодключаемыйМодуль = ПодключаемыйМодуль;
				Возврат Результат;
				
			КонецЕсли;

		Иначе

			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
				 |из реестра Windows
				 |по причине:
				 |Метод %2 вернул %3.'"), Контекст.Идентификатор, "ПодключитьВнешнююКомпонентуАсинх", "Ложь");

			Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаПодключенияКомпоненты(ТекстОшибки);

		КонецЕсли;
		
	Иначе 
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
			           |из реестра Windows
			           |по причине:
			           |Подключить компоненту из реестра Windows возможно только в тонком или толстом клиентах Windows.'"),
			Контекст.Идентификатор);
		
		Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаПодключенияКомпоненты(ТекстОшибки);
		
	КонецЕсли;
	
КонецФункции

// Для вызова из см. ВнешниеКомпонентыКлиент.ПодключитьКомпонентуИзРеестраWindows.
// 
// Параметры:
//  Контекст - см. КонтекстПодключенияКомпонентыИзРеестраWindows.
//
Процедура ПодключитьКомпонентуИзРеестраWindows(Контекст) Экспорт
	
	Если ПодключитьКомпонентуИзРеестраWindowsДоступноПодключение() Тогда
		
		Оповещение = Новый ОписаниеОповещения(
		"ПодключитьКомпонентуИзРеестраWindowsПослеПопыткиПодключения", ЭтотОбъект, Контекст,
		"ПодключитьКомпонентуИзРеестраWindowsПриОбработкеОшибки", ЭтотОбъект);
		
		НачатьПодключениеВнешнейКомпоненты(Оповещение, "AddIn." + Контекст.Идентификатор);
		
	Иначе 
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
			           |из реестра Windows
			           |по причине:
			           |Подключить компоненту из реестра Windows возможно только в тонком или толстом клиентах Windows.'"),
		Контекст.Идентификатор);
		
		ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
		
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ПодключитьКомпонентуИзРеестраWindows.
//
// Параметры:
//  Подключено - Булево
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Процедура ПодключитьКомпонентуИзРеестраWindowsПослеПопыткиПодключения(Подключено, Контекст) Экспорт
	
	Если Подключено Тогда 
		
		ИдентификаторСозданияОбъекта = Контекст.ИдентификаторСозданияОбъекта;
			
		Если ИдентификаторСозданияОбъекта = Неопределено Тогда 
			ИдентификаторСозданияОбъекта = Контекст.Идентификатор;
		КонецЕсли;
		
		Попытка
			ПодключаемыйМодуль = Новый("AddIn." + ИдентификаторСозданияОбъекта);
			Если ПодключаемыйМодуль = Неопределено Тогда 
				ВызватьИсключение НСтр("ru = 'Оператор Новый вернул Неопределено'");
			КонецЕсли;
		Исключение
			ПодключаемыйМодуль = Неопределено;
			ТекстОшибки = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		
		Если ПодключаемыйМодуль = Неопределено Тогда 
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось создать объект внешней компоненты ""%1"", подключенной на клиенте
				           |из реестра Windows,
				           |по причине:
				           |%2'"),
				Контекст.Идентификатор,
				ТекстОшибки);
				
			ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
			
		Иначе 
			ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОПодключении(ПодключаемыйМодуль, Контекст);
		КонецЕсли;
		
	Иначе 
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
			           |из реестра Windows
			           |по причине:
			           |Метод %2 вернул %3.'"),
			Контекст.Идентификатор, "НачатьПодключениеВнешнейКомпоненты", "Ложь");
			
		ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
		
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ПодключитьКомпонентуИзРеестраWindows.
//
// Параметры:
//  ИнформацияОбОшибке - ИнформацияОбОшибке
//  СтандартнаяОбработка - Булево
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Процедура ПодключитьКомпонентуИзРеестраWindowsПриОбработкеОшибки(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
		           |из реестра Windows
		           |по причине:
		           |%2'"),
		Контекст.Идентификатор,
		ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		
	ОбщегоНазначенияСлужебныйКлиент.ПодключитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
	
КонецПроцедуры

// Продолжение процедуры ПодключитьКомпонентуИзРеестраWindows.
Функция ПодключитьКомпонентуИзРеестраWindowsДоступноПодключение()
	
#Если ВебКлиент Тогда
	Возврат Ложь;
#Иначе
	Возврат ОбщегоНазначенияКлиент.ЭтоWindowsКлиент();
#КонецЕсли
	
КонецФункции

#КонецОбласти

#Область УстановитьКомпоненту

// Параметры:
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты
//
Асинх Функция УстановитьКомпонентуАсинх(Контекст) Экспорт
	
	РезультатПроверки = Ждать РезультатПроверкиДоступностиКомпоненты(Контекст);
	
	Если РезультатПроверки.Доступна Тогда 
		Возврат Ждать ОбщегоНазначенияСлужебныйКлиент.УстановитьКомпонентуАсинх(Контекст);
	Иначе
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
			           |из хранилища внешних компонент
			           |по причине:
			           |%2'"),
			Контекст.Идентификатор,
			РезультатПроверки.ОписаниеОшибки);
			
		Возврат ОбщегоНазначенияСлужебныйКлиент.ОшибкаУстановкиКомпоненты(ТекстОшибки);
	КонецЕсли;
	
КонецФункции

Процедура УстановитьКомпоненту(Контекст) Экспорт
	
	Оповещение = Новый ОписаниеОповещения(
		"УстановитьКомпонентуПослеПроверкиДоступности", 
		ЭтотОбъект, 
		Контекст);
	
	ПроверитьДоступностьКомпоненты(Оповещение, Контекст);
	
КонецПроцедуры

// Параметры:
//  Результат - Структура - результат подключения компоненты:
//    * Подключено - Булево - признак подключения;
//    * ПодключаемыйМодуль - ОбъектВнешнейКомпоненты - экземпляр объекта внешней компоненты.
//    * ОписаниеОшибки - Строка - краткое описание ошибки. При отмене пользователем пустая строка.
//  Контекст - см. ОбщегоНазначенияСлужебныйКлиент.КонтекстПодключенияКомпоненты 
//
Процедура УстановитьКомпонентуПослеПроверкиДоступности(Результат, Контекст) Экспорт
	
	Если Результат.Доступна Тогда 
		ОбщегоНазначенияСлужебныйКлиент.УстановитьКомпоненту(Контекст);
	Иначе
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на клиенте
			           |из хранилища внешних компонент
			           |по причине:
			           |%2'"),
			Контекст.Идентификатор,
			Результат.ОписаниеОшибки);
			
		ОбщегоНазначенияСлужебныйКлиент.УстановитьКомпонентуОповеститьОбОшибке(ТекстОшибки, Контекст);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ЗагрузитьКомпонентуИзФайла

// Возвращаемое значение:
//  Структура:
//   * Оповещение - ОписаниеОповещения
//   * Идентификатор - Строка
//   * Версия - Строка
//   * ПараметрыПоискаДополнительнойИнформации - Соответствие
//
Функция КонтекстЗагрузкиКомпонентыИзФайла() Экспорт
	
	Контекст = Новый Структура;
	Контекст.Вставить("Оповещение", Неопределено);
	Контекст.Вставить("Идентификатор", "");
	Контекст.Вставить("Версия", "");
	Контекст.Вставить("ПараметрыПоискаДополнительнойИнформации", Новый Соответствие);
	Возврат Контекст;
	
КонецФункции
	
// Для вызова из ВнешниеКомпонентыКлиент.ЗагрузитьКомпонентуИзФайла.
// 
// Параметры:
//  Контекст - см. КонтекстЗагрузкиКомпонентыИзФайла.
//
Процедура ЗагрузитьКомпонентуИзФайла(Контекст) Экспорт 
	
	Информация = ВнешниеКомпонентыСлужебныйВызовСервера.ИнформацияОСохраненнойКомпоненте(Контекст.Идентификатор, Контекст.Версия);
	
	Если Информация.ДоступнаЗагрузкаИзФайла Тогда
		
		ПараметрыПоискаДополнительнойИнформации = Контекст.ПараметрыПоискаДополнительнойИнформации;
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии", Истина);
		ПараметрыФормы.Вставить("ВернутьРезультатЗагрузкиИзФайла", Истина);
		ПараметрыФормы.Вставить("ПараметрыПоискаДополнительнойИнформации", ПараметрыПоискаДополнительнойИнформации);
		
		Если Информация.Состояние = "НайденаВХранилище"
			Или Информация.Состояние = "ОтключенаАдминистратором" Тогда
			
			ПараметрыФормы.Вставить("ПоказатьДиалогЗагрузкиИзФайлаПриОткрытии", Ложь);
			ПараметрыФормы.Вставить("Ключ", Информация.Ссылка);
		КонецЕсли;
		
		Оповещение = Новый ОписаниеОповещения("ЗагрузитьКомпонентуИзФайлаПослеЗагрузки", ЭтотОбъект, Контекст);
		ОткрытьФорму("Справочник.ВнешниеКомпоненты.ФормаОбъекта", ПараметрыФормы,,,,, Оповещение);
		
	Иначе 
		
		Оповещение = Новый ОписаниеОповещения("ЗагрузитьКомпонентуИзФайлаПослеПредупрежденияДоступности", ЭтотОбъект, Контекст);
		ПоказатьПредупреждение(Оповещение, 
			НСтр("ru = 'Загрузка внешней компоненты прервана
			           |по причине:
			           |Требуются права администратора'"));
		
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
Процедура ЗагрузитьКомпонентуИзФайлаПослеПредупрежденияДоступности(Контекст) Экспорт
	
	Результат = РезультатЗагрузкиКомпоненты();
	Результат.Загружена = Ложь;
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, Результат);
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
Процедура ЗагрузитьКомпонентуИзФайлаПослеЗагрузки(Результат, Контекст) Экспорт
	
	// Результат: 
	// - Структура - Загружено.
	// - Неопределено - Закрыто окно. 
	
	ПользовательЗакрылОкно = (Результат = Неопределено);
	
	Оповещение = Контекст.Оповещение;
	
	Если ПользовательЗакрылОкно Тогда 
		Результат = РезультатЗагрузкиКомпоненты();
		Результат.Загружена = Ложь;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Оповещение, Результат);
	
КонецПроцедуры

// Продолжение процедуры ЗагрузитьКомпонентуИзФайла.
Функция РезультатЗагрузкиКомпоненты() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Загружена", Ложь);
	Результат.Вставить("Идентификатор", "");
	Результат.Вставить("Версия", "");
	Результат.Вставить("Наименование", "");
	Результат.Вставить("ДополнительнаяИнформация", Новый Соответствие);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область ПоискКомпонентыНаПортале

Процедура ПоискКомпонентыНаПорталеПриФормированииРезультата(Результат, Оповещение) Экспорт
	
	Загружена = (Результат = Истина); // При закрытии формы будет Неопределено.
	ВыполнитьОбработкуОповещения(Оповещение, Загружена);
	
КонецПроцедуры

#КонецОбласти

#Область ОбновитьКомпонентыСПортала

// Параметры:
//  Оповещение - ОписаниеОповещения
//  ОбновляемыеКомпоненты - Массив из СправочникСсылка.ВнешниеКомпоненты
//
Процедура ОбновитьКомпонентыСПортала(Оповещение, ОбновляемыеКомпоненты) Экспорт
	
	ОповещениеФормы = Новый ОписаниеОповещения("ОбновитьКомпонентыСПорталаПриФормированииРезультата", ЭтотОбъект, Оповещение);
	ВнешниеКомпонентыКлиентЛокализация.ОбновитьКомпонентыСПортала(ОповещениеФормы, ОбновляемыеКомпоненты);
	
КонецПроцедуры

Процедура ОбновитьКомпонентыСПорталаПриФормированииРезультата(Результат, Оповещение) Экспорт
	
	ВыполнитьОбработкуОповещения(Оповещение, Неопределено);
	
КонецПроцедуры

#КонецОбласти

#Область СохранитьКомпонентуВФайл

// Параметры:
//  ВнешняяКомпонентаСсылка - СправочникСсылка.ВнешниеКомпоненты
//                          - Массив из СправочникСсылка.ВнешниеКомпоненты
//
Процедура СохранитьКомпонентуВФайл(ВнешняяКомпонентаСсылка) Экспорт
	
	Если ТипЗнч(ВнешняяКомпонентаСсылка) = Тип("Массив") Тогда
		Ссылки = ВнешняяКомпонентаСсылка;
	Иначе
		Ссылки = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ВнешняяКомпонентаСсылка);
	КонецЕсли;
	ОписаниеФайлов = ВнешниеКомпонентыСлужебныйВызовСервера.ОписаниеФайловКомпонент(Ссылки);

	Если Ссылки.Количество() = 1 Тогда
		
		ПараметрыСохранения = ФайловаяСистемаКлиент.ПараметрыСохраненияФайла();
		ПараметрыСохранения.Диалог.Заголовок = НСтр("ru = 'Выберите файл для сохранения внешней компоненты'");
		ПараметрыСохранения.Диалог.Фильтр    = НСтр("ru = 'Файлы внешних компонент (*.zip)|*.zip'")+"|"
			+ СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Все файлы (%1)|%1'"), ПолучитьМаскуВсеФайлы());
		
		Оповещение = Новый ОписаниеОповещения("СохранитьКомпонентуВФайлПослеПолученияФайлов", ЭтотОбъект);
		ФайловаяСистемаКлиент.СохранитьФайл(Оповещение, ОписаниеФайлов[0].Хранение, ОписаниеФайлов[0].Имя, ПараметрыСохранения);
		
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("СохранитьКомпонентыВФайлПослеВыбораКаталога", ЭтотОбъект, ОписаниеФайлов);
	ФайловаяСистемаКлиент.ВыбратьКаталог(Оповещение, НСтр("ru = 'Выберите каталог для сохранения внешних компонент'"));
	
КонецПроцедуры

// Продолжение процедуры СохранитьКомпонентуВФайл.
Процедура СохранитьКомпонентыВФайлПослеВыбораКаталога(Каталог, ОписаниеФайлов) Экспорт
	
	Если ПустаяСтрока(Каталог) Тогда
		Возврат;
	КонецЕсли;
	
	СохраняемыеФайлы = Новый Массив;
	Для Каждого ОписаниеФайла Из ОписаниеФайлов Цикл
		СохраняемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ОписаниеФайла.Имя, ОписаниеФайла.Хранение));
	КонецЦикла;
	
	ПараметрыСохранения = ФайловаяСистемаКлиент.ПараметрыСохраненияФайлов();
	ПараметрыСохранения.Интерактивно = Ложь;
	ПараметрыСохранения.Диалог.Каталог = Каталог;
	ФайловаяСистемаКлиент.СохранитьФайлы(Новый ОписаниеОповещения(
		"СохранитьКомпонентуВФайлПослеПолученияФайлов", ЭтотОбъект), 
		СохраняемыеФайлы, ПараметрыСохранения);

КонецПроцедуры

// Продолжение процедуры СохранитьКомпонентуВФайл.
Процедура СохранитьКомпонентуВФайлПослеПолученияФайлов(ПолученныеФайлы, Контекст) Экспорт
	
	Если ПолученныеФайлы <> Неопределено 
		И ПолученныеФайлы.Количество() > 0 Тогда
		
		ТекстСообщения = ?(ПолученныеФайлы.Количество() = 1, 
			НСтр("ru = 'Внешняя компонента успешно сохранена в файл.'"),
			НСтр("ru = 'Внешние компоненты успешно сохранены в файлы.'"));
		
		ПоказатьОповещениеПользователя(НСтр("ru = 'Сохранение в файл'"),,
			ТекстСообщения, БиблиотекаКартинок.Успешно32);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

