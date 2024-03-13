#Использовать gitrunner
#Использовать fs

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("PATH", "test.json", "Путь к json-файлу с настройками")
			.Обязательный(Ложь);

	Команда.Опция("s step", "", "Перейти у казанному шагу и остановиться");
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	Сообщить("Подготовка...");

	ФайлПараметров = Новый Файл(Команда.ЗначениеАргумента("PATH"));
	Если Не ФайлПараметров.Существует() Тогда
		ВызватьИсключение "Не найден файл с параметрами " + ФайлПараметров.ПолноеИмя;
	КонецЕсли;

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.ОткрытьФайл(ФайлПараметров.ПолноеИмя);
	Настройки = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	УказанШаг = Команда.ЗначениеОпции("step");
	Если ЗначениеЗаполнено(УказанШаг) Тогда
		Настройки.Вставить("УказанШаг", УказанШаг);
	КонецЕсли;

	НашРепо = Новый ГитРепозиторий();
	НашРепо.УстановитьРабочийКаталог(ТекущийКаталог());

	ВыполнитьПоНастройкам(НашРепо, Настройки);

КонецПроцедуры

Функция ВыполнитьПоНастройкам(Знач НашРепо, Знач Настройки) Экспорт

	Перем Пушить, УказанШаг;

	ПутьКДонору = Настройки.Донор.Путь;
	КаталогДонора = Новый Файл(ПутьКДонору);
	Если Не КаталогДонора.Существует() Или Не КаталогДонора.ЭтоКаталог() Тогда
		ВызватьИсключение "Не найден путь (или это не каталог) к репо-донору " + ПутьКДонору;
	КонецЕсли;

	Донор = Новый ГитРепозиторий();
	Донор.УстановитьРабочийКаталог(ПутьКДонору);

	ФайлыДляПереноса = Настройки.Файлы;
	Пушить = Не Настройки.Свойство("Пушить", Пушить) Или Пушить = Истина;
	Настройки.Свойство("УказанШаг", УказанШаг);
	
	Для Каждого Коммит Из Настройки.Коммиты Цикл
		Если Не ЗначениеЗаполнено(УказанШаг) Или Коммит.Ключ = УказанШаг Тогда
			ОбработатьКоммит(НашРепо, Донор, Коммит, ФайлыДляПереноса, Пушить);
		КонецЕсли;
	КонецЦикла;

	Сообщить("Команда успешно выполнена.");

	Возврат Истина;
КонецФункции

Функция ОбработатьКоммит(Знач НашРепо, Знач Донор, Знач Коммит, Знач ФайлыДляПереноса, Знач Пушить)

	Сообщить(СтрШаблон("Обработка шага %1 (%2)...", Коммит.Ключ, Коммит.Значение));

	Донор.ПерейтиВВетку(Коммит.Значение, , Истина);
	
	Донор.ВыполнитьКоманду(КомандаСообщенияКоммита());
	СообщениеКоммита = СокрЛП(Донор.ПолучитьВыводКоманды());

	КаталогДонора = Донор.ПолучитьРабочийКаталог();
	КаталогПриемника = НашРепо.ПолучитьРабочийКаталог();
	
	Сообщить("Перенос файлов...");

	Для Каждого ФайлДляПереноса Из ФайлыДляПереноса Цикл
		
		Источник = Новый Файл(ОбъединитьПути(КаталогДонора, ФайлДляПереноса));
		Приемник = Новый Файл(ОбъединитьПути(КаталогПриемника, ФайлДляПереноса));

		ФС.ОбеспечитьКаталог(Приемник.Путь);
		Если Источник.ЭтоКаталог() Тогда
			ФС.КопироватьСодержимоеКаталога(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		Иначе
			КопироватьФайл(Источник.ПолноеИмя, Приемник.ПолноеИмя);
		КонецЕсли;
	КонецЦикла;

	Сообщить("Фиксация...");

	НашРепо.ДобавитьФайлВИндекс(".");
	НашРепо.Закоммитить(СообщениеКоммита);
	
	Если Пушить Тогда
		Сообщить("Отправка...");
		НашРепо.Отправить();
	КонецЕсли;

	Возврат Истина;
КонецФункции

Функция КомандаСообщенияКоммита()
	Команда = Новый Массив;
	Команда.Добавить("log -1 --pretty=%B");
	Возврат Команда;
КонецФункции
