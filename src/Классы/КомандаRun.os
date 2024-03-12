#Использовать gitrunner
#Использовать fs

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("PATH", "test.json", "Путь к json-файлу с настройками")
			.Обязательный(Ложь);

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	Сообщить("Инициализация параметров...");

	ФайлПараметров = Новый Файл(Команда.ЗначениеАргумента("PATH"));
	Если Не ФайлПараметров.Существует() Тогда
		ВызватьИсключение "Не найден файл с параметрами " + ФайлПараметров.ПолноеИмя;
	КонецЕсли;

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.ОткрытьФайл(ФайлПараметров.ПолноеИмя);
	Параметры = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();

	ПутьКДонору = Параметры["Донор"]["Путь"];
	КаталогДонора = Новый Файл(ПутьКДонору);
	Если Не КаталогДонора.Существует() Или Не КаталогДонора.ЭтоКаталог() Тогда
		ВызватьИсключение "Не найден путь (или это не каталог) к репо-донору " + ПутьКДонору;
	КонецЕсли;

	НашРепо = Новый ГитРепозиторий();
	НашРепо.УстановитьРабочийКаталог(ТекущийКаталог());

	Донор = Новый ГитРепозиторий();
	Донор.УстановитьРабочийКаталог(ПутьКДонору);

	ФайлыДляПереноса = Параметры["Файлы"];
	Для Каждого Коммит Из Параметры["Коммиты"] Цикл
		ОбработатьКоммит(НашРепо, Донор, Коммит, ФайлыДляПереноса);
	КонецЦикла;

	Сообщить("Команда успешно выполнена.");

КонецПроцедуры

Процедура ОбработатьКоммит(Знач НашРепо, Знач Донор, Знач Коммит, Знач ФайлыДляПереноса)

	Донор.ПерейтиВВетку(Коммит, , Истина);

	Для Каждого ФайлДляПереноса Из ФайлыДляПереноса Цикл
		
		Источник = Новый Файл(ОбъединитьПути(Донор.ПолучитьРабочийКаталог(), ФайлДляПереноса));
		Приемник = Новый Файл(ОбъединитьПути(НашРепо.ПолучитьРабочийКаталог(), ФайлДляПереноса));

		ФС.ОбеспечитьКаталог(Приемник.Путь);
		Если Источник.ЭтоКаталог() Тогда
			ФС.КопироватьСодержимоеКаталога(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		Иначе
			КопироватьФайл(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		КонецЕсли;
	КонецЦикла;

	НашРепо.Закоммитить(Коммит, Истина);
	НашРепо.Отправить();

	Сообщить("Обработан коммит " + Коммит);
КонецПроцедуры
